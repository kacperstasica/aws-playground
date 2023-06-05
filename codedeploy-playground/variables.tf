variable "code_deploy_service_role_name" {
  type        = string
  description = "Name of the CodeDeploy service role"
}
variable "ec2_role_for_code_deploy_name" {
  type        = string
  description = "Name of the EC2 role for CodeDeploy"
}
variable "code_deploy_app_name" {
  type        = string
  description = "Name of the CodeDeploy application"
}
variable "code_deploy_compute_platform" {
  type        = string
  description = "Compute platform for CodeDeploy"
}
variable "image_name" {
  type        = string
  description = "Name of the image"
}
variable "public_key_path" {
  type        = string
  description = "Path to the public key"
}
variable "my_ip" {
  type        = string
  description = "IP address of the user"
}
variable "acl" {
  type        = string
  description = "The ACL for the bucket"
}
variable "bucket_name" {
  type        = string
  description = "Name of the bucket"
}
variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}
variable "public_subnet_cidr_block" {
  type        = string
  description = "CIDR block for the subnet"
}
variable "availability_zone" {
  type        = string
  description = "Availability zone"
}
variable "s3_object_source_path" {
  type        = string
  description = "Path to the object in the bucket"
}