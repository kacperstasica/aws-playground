provider "aws" {
  region = "eu-central-1"
}

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

#module "policies" {
#  source = "./modules/policies"
#  public_key_path = var.public_key_path
#}