output "ec2_public_ip" {
  value = module.app.instance.public_ip
}
