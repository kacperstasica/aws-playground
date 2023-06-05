variable region {
  type = string
  description = "AWS region"
}

variable "env_name" {
  type = string
}

variable "function_name" {
    type = string
}

variable "function_handler" {
    type = string
}

variable "function_runtime" {
    type = string
}

variable "function_timeout_in_seconds" {
  type = number
}
