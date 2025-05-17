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
  availability_zone = "us-east-1a"
  tags = {
    Name                                        = "privatesubnet-${var.application}"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "ES_privatesubnet2" {
  vpc_id     = aws_vpc.EasyShop.id
  cidr_block = var.private_subnet2_cidr
  availability_zone = "us-east-1b"
  tags = {
    Name = "privatesubnet2-${var.application}"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "intrasubnet" {
  vpc_id     = aws_vpc.EasyShop.id
  cidr_block = var.intrasubnet_cidr
  availability_zone = "us-east-1a"
  tags = {
    Name = "intrasubnet-${var.application}"
     "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "intrasubnet2" {
  vpc_id     = aws_vpc.EasyShop.id
  cidr_block = var.intrasubnet2_cidr
  availability_zone = "us-east-1b"
  tags = {
    Name = "intrasubnet2-${var.application}"
     "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
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

resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "EIP-NAT-${var.application}"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.ES_publicsubnet.id

  tags = {
    Name = "NAT-Gateway-${var.application}"
  }

  depends_on = [aws_internet_gateway.my_igw]
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.EasyShop.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private-route-table-${var.application}"
  }
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.ES_privatesubnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.ES_privatesubnet2.id
  route_table_id = aws_route_table.private_route_table.id
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
    volume_size           = 20 # <-- Increase this number to increase storage (in GB)
    volume_type           = "gp3"
    delete_on_termination = true
  }
}