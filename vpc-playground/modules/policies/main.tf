data "aws_iam_policy_document" "ec2_trusted_entity" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "aws_elastic_beanstalk_role" {
  name               = "aws-elasticbeanstalk-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trusted_entity.json
  permissions_boundary = "arn:aws:iam::${local.account_id}:policy/netguru-boundary"
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key-pair"
  public_key = file(var.public_key_path)
}

resource "aws_iam_instance_profile" "aws_elastic_beanstalk_instance_profile" {
  name = "aws-elasticbeanstalk-ec2-profile"
  role = aws_iam_role.aws_elastic_beanstalk_role.name
}

resource "aws_iam_role_policy_attachment" "web-tier-attach" {
  role       = aws_iam_role.aws_elastic_beanstalk_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "worker-tier-attach" {
  role       = aws_iam_role.aws_elastic_beanstalk_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "docker-attach" {
  role       = aws_iam_role.aws_elastic_beanstalk_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

