terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

#resource "aws_vpc" "prediction-vpc" {
#  cidr_block = var.vpc_cidr_block
#  tags = {
#    Name = "prediction-vpc"
#  }
#}

module "vpc" {
  name    = "prediction-vpc"
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.19.0"

  azs                = var.availability_zones
  cidr               = "10.0.0.0/16"
  create_igw         = true
  enable_nat_gateway = true
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
}


resource "aws_security_group" "this" {
  vpc_id = module.vpc.vpc_id
  name = "prediction-api-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "prediction-sg"
  }
}

#resource "aws_internet_gateway" "prediction-igw" {
#  #  vpc_id = aws_vpc.prediction-vpc.id
#  vpc_id = module.vpc.vpc_id
#  tags = {
#    Name : "prediction-igw"
#  }
#}

#resource "aws_default_route_table" "prediction-rtb" {
#  #  default_route_table_id = aws_vpc.prediction-vpc.default_route_table_id
#  default_route_table_id = module.vpc.default_route_table_id
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.prediction-igw.id
#  }
#  tags = {
#    Name : "prediction-main-rtb"
#  }
#}

#module "subnets" {
#  source = "cloudposse/dynamic-subnets/aws"
#  version = "~> 0.40.0"
#  namespace           = "rdx"
#  stage               = "dev"
#  name                = "prediction-api"
##  vpc_id              = aws_vpc.prediction-vpc.id
#  vpc_id              = module.vpc.vpc_id
#  igw_id              = aws_internet_gateway.prediction-igw.id
#  cidr_block          = var.subnet_cidr_block
#  availability_zones  = var.availability_zones
#}

#
#module "security_group" {
#  source = "terraform-aws-modules/security-group/aws//modules/http-80"
#
#  name = "prediction-api-sg"
#  #  vpc_id              = aws_vpc.prediction-vpc.id
#  vpc_id              = module.vpc.vpc_id
#  ingress_cidr_blocks = var.ingress_cidr_blocks
#}
#
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name = "prediction-api-alb"
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.this.id]

  target_groups = [
    {
      name             = "prediction-api-tg"
      backend_port     = 80
      backend_protocol = "HTTP"
      force_delete     = true
      target_type      = "ip"
      vpc_id = module.vpc.vpc_id
      health_check = {
        path    = "/docs"
        port    = 80
        matcher = "200-399"
      }
    }
  ]
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
}

resource "aws_ecr_repository" "api_ecr" {
  name = "prediction-api-repository"
}

resource "aws_ecs_cluster" "cluster" {
  name = "prediction-api-cluster"

}

module "container_definition" {
  source = "cloudposse/ecs-container-definition/aws"
  version = "0.50.0"

  container_name  = "prediction-api-container"
  container_image = "${local.account_id}.dkr.ecr.eu-central-1.amazonaws.com/${aws_ecr_repository.api_ecr.name}:latest"
  port_mappings   = [
    {
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }
  ]
}


module "ecs_alb_service_task" {
  source  = "cloudposse/ecs-alb-service-task/aws"
  version = "~> 0.50.0"

  namespace                 = "rdx"
  stage                     = "dev"
  name                      = "prediction-api"
  container_definition_json = module.container_definition.json_map_encoded_list
  ecs_cluster_arn           = aws_ecs_cluster.cluster.arn
  launch_type               = "FARGATE"
  vpc_id             = module.vpc.vpc_id
  security_group_ids = [aws_security_group.this.id]
  subnet_ids         = module.vpc.public_subnets
  alb_security_group = aws_security_group.this.id

  health_check_grace_period_seconds = 60
  ignore_changes_task_definition    = false

  ecs_load_balancers = [
    {
      target_group_arn = module.alb.target_group_arns[0]
      elb_name         = ""
      container_name   = "prediction-api-container"
      container_port   = 80
  }]

  permissions_boundary = "arn:aws:iam::${local.account_id}:policy/${var.permissions_boundary_name}"
}