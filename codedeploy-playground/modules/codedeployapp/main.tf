data "aws_caller_identity" "current" {}

resource "aws_codedeploy_app" "code_deploy_app" {
  compute_platform = var.code_deploy_compute_platform
  name             = var.code_deploy_app_name
}

resource "aws_codedeploy_deployment_group" "code_deploy_group" {
  service_role_arn      = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.code_deploy_service_role_name}"
  app_name              = aws_codedeploy_app.code_deploy_app.name
  deployment_group_name = "DevelopmentGroup"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Environment"
      type  = "KEY_AND_VALUE"
      value = "Development"
    }
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

resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key-pair"
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "demo-sg" {
  vpc_id = var.vpc_id
  name   = "dev-demo-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
    Name = "dev-sg"
  }
}

resource "aws_instance" "demo-server" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = "t2.micro"

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.demo-sg.id]
  availability_zone      = var.availability_zone

  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh-key.key_name

  tags = {
    Name = "dev-server"
  }
}

resource "aws_s3_bucket" "codedeploy-demo" {
  bucket        = "test-codedeploy-demo"
  force_destroy = true

  tags = {
    Name = "test-codedeploy-demo"
  }
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.codedeploy-demo.id
  key    = "SampleApp_Linux.zip"
  source = var.s3_object_source_path

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5(var.s3_object_source_path)
}