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

data "aws_caller_identity" "this" {}

locals {
  account_id = data.aws_caller_identity.this.account_id
  function_name = var.function_name
  function_handler = var.function_handler
  function_runtime = var.function_runtime
  function_timeout_in_seconds = var.function_timeout_in_seconds

  function_source_dir = "${path.module}/app/${local.function_name}"
}

resource "aws_lambda_function" "function" {
  function_name = "${local.function_name}-${var.env_name}"
  handler = local.function_handler
  runtime = local.function_runtime
  timeout = local.function_timeout_in_seconds

  filename = "${local.function_source_dir}.zip"
  source_code_hash = data.archive_file.function_zip.output_base64sha256

  role = aws_iam_role.function_role.arn

  environment {
    variables = {
      ENVIRONMENT = var.env_name
    }
  }
}

data "archive_file" "function_zip" {
  type = "zip"
  source_dir = local.function_source_dir
  output_path = "${local.function_source_dir}.zip"
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "function_role" {
  name = "${local.function_name}-${var.env_name}"
  assume_role_policy = data.aws_iam_policy_document.lambda_policy.json

  permissions_boundary = "arn:aws:iam::${local.account_id}:policy/netguru-boundary"
}