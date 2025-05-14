provider "aws" {
  region = var.region
}

resource "aws_vpc" "EasyShop" {

  cidr_block = var.cidr_vpc #"10.0.0.0/16"
  tags = {
    name = "VPC-${var.application}" #"Easyshop"
  }

}
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.EasyShop.id

  tags = {
    Name = "IGW-${var.application}"
  }
}



resource "aws_subnet" "ES_publicsubnet" {
  vpc_id     = aws_vpc.EasyShop.id
  cidr_block = var.public_subnet1_cidr
  tags = {
    Name = "publicsubnet-${var.application}"
  }
}

resource "aws_subnet" "ES_privatesubnet" {
  vpc_id     = aws_vpc.EasyShop.id
  cidr_block = var.private_subnet1_cidr
  tags = {
    Name = "privatesubnet-${var.application}"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.EasyShop.id
  route {
    cidr_block = var.cidr_block_internet_access #"0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "route_table-${var.application}"
  }

}

resource "aws_route_table_association" "routetable_association_1" {
  subnet_id      = aws_subnet.ES_publicsubnet.id
  route_table_id = aws_route_table.route_table.id
}



resource "aws_key_pair" "Easyshop_keypair" {
  key_name   = "file1"
  public_key = file("E:/DEVOPS/Project/EasyShop/file1.pub")
}

resource "aws_security_group" "Easyshop_securitygroup" {
  name        = "${var.application}_securitygroup"
  description = "Security group"
  vpc_id      = aws_vpc.EasyShop.id
  tags = {
    Name = "${var.application}_securitygroup"
  }
}

resource "aws_vpc_security_group_ingress_rule" "Easyshop_ingress" {
  security_group_id = aws_security_group.Easyshop_securitygroup.id

  cidr_ipv4   = var.cidr_block_internet_access
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "Easyshop_ingress3" {
  security_group_id = aws_security_group.Easyshop_securitygroup.id

  cidr_ipv4   = var.cidr_block_internet_access
  from_port   = 8080
  ip_protocol = "tcp"
  to_port     = 8080
}

resource "aws_vpc_security_group_ingress_rule" "Easyshop_ingress2" {
  security_group_id = aws_security_group.Easyshop_securitygroup.id

  cidr_ipv4   = var.cidr_block_internet_access
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}
resource "aws_vpc_security_group_egress_rule" "Easyshop_egress" {
  security_group_id = aws_security_group.Easyshop_securitygroup.id

  cidr_ipv4   = var.cidr_block_internet_access
  ip_protocol = "-1"
}

resource "aws_instance" "easyshop_instance" {
  tags = {
    Name = "${var.application}_instance"
  }
  ami                         = var.instance_image #"ami-0866a3c8686eaeeba"
  instance_type               = var.instance_type  #"t2.micro"
  key_name                    = aws_key_pair.Easyshop_keypair.id
  subnet_id                   = aws_subnet.ES_publicsubnet.id
  vpc_security_group_ids      = [aws_security_group.Easyshop_securitygroup.id]
  count                       = var.instance_count
  associate_public_ip_address = true
  user_data                   = file("${path.module}/docker_installation.sh")

  root_block_device {
    volume_size = 20 # <-- Increase this number to increase storage (in GB)
    volume_type = "gp3"
    delete_on_termination = true
  }
}