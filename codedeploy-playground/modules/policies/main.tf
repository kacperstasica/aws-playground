data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "code_deploy_service_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "ec2_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy" "code_deploy_service_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

data "aws_iam_policy" "s3_readonly_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_iam_role" "code_deploy_service_role" {
  name                 = var.code_deploy_service_role_name
  assume_role_policy   = data.aws_iam_policy_document.code_deploy_service_policy_document.json
  permissions_boundary = "arn:aws:iam::${local.account_id}:policy/netguru-boundary"
}


resource "aws_iam_role" "ec2_role_for_code_deploy" {
  name                 = var.ec2_role_for_code_deploy_name
  assume_role_policy   = data.aws_iam_policy_document.ec2_policy.json
  permissions_boundary = "arn:aws:iam::${local.account_id}:policy/netguru-boundary"
}
