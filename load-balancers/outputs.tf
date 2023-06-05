output "ec2_public_ipv4_addresses" {
  value = [for instance in aws_instance.lb-test-servers: instance.public_ip]
}
