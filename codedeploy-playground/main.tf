provider "aws" {
  region = "eu-central-1"
}

#terraform {
#  required_version = ">= 0.12.0"
#  backend "s3" {
#    bucket = "demo-bucket-kacperstasica-dev"
#    key    = "myapp/state.tfstate"
#    region = "eu-central-1"
#  }
#}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr_block

  azs            = [var.availability_zone]
  public_subnets = [var.public_subnet_cidr_block]
  public_subnet_tags = {
    Name = "dev-public-subnet-1"
  }

  tags = {
    Name = "dev-vpc"
  }
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = var.bucket_name
  acl    = var.acl

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  # Allow deletion of non-empty bucket
  force_destroy = true

  versioning = {
    enabled = true
  }
}

module "policies" {
  source                        = "./modules/policies"
  ec2_role_for_code_deploy_name = var.ec2_role_for_code_deploy_name
  code_deploy_service_role_name = var.code_deploy_service_role_name
}

module "app" {
  source                        = "./modules/codedeployapp"
  availability_zone             = var.availability_zone
  code_deploy_app_name          = var.code_deploy_app_name
  code_deploy_service_role_name = var.code_deploy_service_role_name
  code_deploy_compute_platform  = var.code_deploy_compute_platform
  subnet_id                     = module.vpc.public_subnets[0]
  vpc_id                        = module.vpc.vpc_id
  my_ip                         = var.my_ip
  public_key_path               = var.public_key_path
  image_name                    = var.image_name
  s3_object_source_path         = var.s3_object_source_path
}
