variable "region" {
  type = string
}
variable "availability_zone" {
  type = string
}
variable "availability_zones" {
  type = list(string)
}
variable "my_ip" {
  type = string
}
variable "image_name" {
  type = string
}
variable "public_key_path" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "instance_tags" {
  description = "Tags for the EC2 instances"
  type        = map(string)
  default = {
    "instance-1" = "my-lb-testing-1-server",
    "instance-2" = "my-lb-testing-2-server"
  }
}
