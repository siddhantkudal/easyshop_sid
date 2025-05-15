output "ip_public" {
  value = aws_instance.easyshop_instance[*].public_ip
}

output "vpcId" {
    value = aws_vpc.EasyShop.id
}

output "privatesubnetid" {
  value = aws_subnet.ES_privatesubnet.id
}

output "intrasubnetid" {
    value = aws_subnet.intrasubnet.id
}