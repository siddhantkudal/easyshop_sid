output "ip_public" {
  value = aws_instance.easyshop_instance[*].public_ip
}

output "vpcId" {
  value = aws_vpc.EasyShop.id
}


output "publicsubnet1" {
  value = aws_subnet.ES_publicsubnet1.id
}

output "publicsubnet2" {
  value = aws_subnet.ES_publicsubnet2.id
}

output "privatesubnetid1" {
  value = aws_subnet.ES_privatesubnet1.id
}

output "privatesubnetid2" {
  value = aws_subnet.ES_privatesubnet2.id
}

output "intrasubnetid1" {
  value = aws_subnet.intrasubnet1.id
}

output "intrasubnetid2" {
  value = aws_subnet.intrasubnet2.id
}

output "debug_key_name" {
  value = aws_key_pair.Easyshop_keypair.key_name
}