variable "code_deploy_service_role_name" {
  type        = string
  description = "Name of the CodeDeploy service role"
}
variable "ec2_role_for_code_deploy_name" {
  type        = string
  description = "Name of the EC2 role for CodeDeploy"
}
