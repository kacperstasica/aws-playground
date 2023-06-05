terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  name    = "lb-testing-vpc"
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.19.0"

  azs                = var.availability_zones
  cidr               = "10.0.0.0/16"
  create_igw         = true
  enable_nat_gateway = true
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
}

resource "aws_security_group" "demo-sg-ec2" {
  vpc_id = module.vpc.vpc_id
  name   = "lb-testing-api-sg-ec2"

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
    Name = "lb-testing-sg-ec2"
  }
}

resource "aws_security_group" "demo-sg-load-balancer" {
  vpc_id = module.vpc.vpc_id
  name   = "lb-testing-api-sg-load-balancer"

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
    Name = "lb-testing-sg-load-balancer"
  }
}


data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = [var.image_name]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "lb-test-servers" {
  # Creates two identical aws ec2 instances
  for_each = var.instance_tags

  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.demo-sg-ec2.id]
  availability_zone      = var.availability_zone

  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh-key.key_name

  user_data_replace_on_change = true
  user_data                   = file("user_data.sh")

  tags = {
    # The count.index allows you to launch a resource
    # starting with the distinct index number 0 and corresponding to this instance.
    Name = each.value
  }
}


resource "aws_key_pair" "ssh-key" {
  key_name   = "lb-testing-server-key-pair"
  public_key = file(var.public_key_path)
}


resource "aws_lb_target_group" "this" {
  name     = "demo-tg-alb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}

resource "aws_lb_target_group_attachment" "this" {
  for_each         = aws_instance.lb-test-servers
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = each.value.id
  port             = 80
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }
}

resource "aws_lb" "test" {
  name               = "my-test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.demo-sg-load-balancer.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = true

  #  access_logs {
  #    bucket  = aws_s3_bucket.lb_logs.id
  #    prefix  = "test-lb"
  #    enabled = true
  #  }

  tags = {
    Environment = "dev-test-load-balancer"
  }
}
