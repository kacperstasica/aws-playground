variable "region" {
  description = "The AWS region to create resources in"
}

variable "project_name" {
  default     = "django-aws"
  description = "Project name to use in resource names"
}

variable "availability_zones" {
  description = "A list of availability zones to use in the region"
  type        = list(string)
}

variable "permissions_boundary_name" {
  description = "The name of the permissions boundary to use for IAM roles"
  type        = string
}

variable "ecs_prod_backend_retention_days" {
  description = "The number of days to retain ECS prod backend logs"
  default     = 30
}

variable "prod_backend_secret_key" {
  description = "production Django's SECRET_KEY"
}

variable "prod_rds_db_name" {
  description = "production RDS database name"
  type        = string
}

variable "prod_rds_username" {
  description = "production RDS database username"
  type        = string
}

variable "prod_rds_password" {
  description = "production RDS database password"
  type        = string
}

variable "prod_rds_instance_class" {
  description = "production RDS instance class"
  type        = string
}