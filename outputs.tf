output "aws_ec2_public_ip" {
  value = module.myapp-webserver.myapp-ec2.public_ip
}