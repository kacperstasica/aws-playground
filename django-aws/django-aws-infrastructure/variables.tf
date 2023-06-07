variable "region" {
  default     = "eu-central-1"
  description = "The AWS region to create resources in"
}

variable "project_name" {
  default     = "django-aws"
  description = "Project name to use in resource names"
}

variable "availability_zones" {
  description = "A list of availability zones to use in the region"
  default     = ["eu-central-1a", "eu-central-1c"]
}

variable "permissions_boundary_name" {
  description = "The name of the permissions boundary to use for IAM roles"
  type        = string
}

variable "ecs_prod_backend_retention_days" {
  description = "The number of days to retain ECS prod backend logs"
  default     = 30
}