output "ip_public" {
  value = aws_instance.easyshop_instance[*].public_ip
}

output "vpcId" {
  value = aws_vpc.EasyShop.id
}

output "privatesubnetid" {
  value = aws_subnet.ES_privatesubnet.id
}

output "privatesubnetid2" {
  value = aws_subnet.ES_privatesubnet2.id
}

output "intrasubnetid" {
  value = aws_subnet.intrasubnet.id
}

output "intrasubnetid2" {
  value = aws_subnet.intrasubnet2.id
}