output "ip_public" {
  value = aws_instance.easyshop_instance[*].public_ip
}