# Production cluster
resource "aws_ecs_cluster" "prod" {
  name = "django-aws-prod"
}

# Backend web task definition and service
resource "aws_ecs_task_definition" "prod_backend_web" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  family = "backend-web"
  container_definitions = templatefile(
    "templates/backend_container.json.tpl",
    {
      region       = var.region
      name         = "prod-backend-web"
      image        = aws_ecr_repository.backend.repository_url
      command      = ["gunicorn", "-w", "3", "-b", ":8000", "django_aws.wsgi:application"]
      log_group    = aws_cloudwatch_log_group.prod_backend.name
      log_stream   = aws_cloudwatch_log_stream.prod_backend_web.name
      rds_db_name  = var.prod_rds_db_name
      rds_username = var.prod_rds_username
      rds_password = var.prod_rds_password
      rds_hostname = aws_db_instance.prod.address
    }
  )
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.ecs_task_execution.arn
}

resource "aws_ecs_service" "prod_backend_web" {
  name                               = "prod-backend-web"
  cluster                            = aws_ecs_cluster.prod.id
  task_definition                    = aws_ecs_task_definition.prod_backend_web.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  enable_execute_command             = true

  load_balancer {
    target_group_arn = aws_lb_target_group.prod_backend.arn
    container_name   = "prod-backend-web"
    container_port   = 8000
  }

  network_configuration {
    subnets          = [aws_subnet.prod_private_1.id, aws_subnet.prod_private_2.id]
    security_groups  = [aws_security_group.prod_ecs_backend.id]
    assign_public_ip = false
  }
}

# Security group
resource "aws_security_group" "prod_ecs_backend" {
  name        = "prod-ecs-backend"
  description = "Allow inbound traffic from ALB"
  vpc_id      = aws_vpc.prod.id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Roles and Policies
resource "aws_iam_role" "prod_backend_task" {
  name = "prod-backend-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Sid = ""
      }
    ]
  })

  inline_policy {
    name = "prod-backend-task-ssmmessages"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  permissions_boundary = "arn:aws:iam::${local.account_id}:policy/${var.permissions_boundary_name}"
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "ecs-task-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Sid = ""
      }
    ]
  })

  permissions_boundary = "arn:aws:iam::${local.account_id}:policy/${var.permissions_boundary_name}"
}

resource "aws_iam_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  name       = "ecs-task-execution-policy-attachment"
  roles      = [aws_iam_role.ecs_task_execution.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Cloudwatch logs
resource "aws_cloudwatch_log_group" "prod_backend" {
  name              = "prod-backend"
  retention_in_days = var.ecs_prod_backend_retention_days
}

resource "aws_cloudwatch_log_stream" "prod_backend_web" {
  name           = "prod-backend-web"
  log_group_name = aws_cloudwatch_log_group.prod_backend.name
}
