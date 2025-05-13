provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "ES" {

  cidr_block = "10.0.0.0/16"
  tags = {
    name = "Easyshop"
  }

}
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.ES.id

  tags = {
    Name = "my-internet-gateway"
  }
}



resource "aws_subnet" "ES_publicsubnet" {
  vpc_id     = aws_vpc.ES.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "ES_publicsubnet"
  }
}

resource "aws_subnet" "ES_privatesubnet" {
  vpc_id     = aws_vpc.ES.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "ES_privatesubnet"
  }
}

resource "aws_route_table" "route_table" {
    vpc_id = aws_vpc.ES.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_igw.id
    }
    tags = {
        Name = "route_table"
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
  name        = "Easyshop_securitygroup"
  description = "Security group"
  vpc_id      = aws_vpc.ES.id
  tags = {
    Name = "Easyshop_securitygroup"
  }
}

resource "aws_vpc_security_group_ingress_rule" "Easyshop_ingress" {
  security_group_id = aws_security_group.Easyshop_securitygroup.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "Easyshop_ingress2" {
  security_group_id = aws_security_group.Easyshop_securitygroup.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}
resource "aws_vpc_security_group_egress_rule" "Easyshop_egress" {
  security_group_id = aws_security_group.Easyshop_securitygroup.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_instance" "easyshop_instance" {
  tags = {
    name = "easyshop_instance"
  }
  ami                    = "ami-0866a3c8686eaeeba"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.Easyshop_keypair.id
  subnet_id              = aws_subnet.ES_publicsubnet.id
  vpc_security_group_ids = [aws_security_group.Easyshop_securitygroup.id]
  associate_public_ip_address = true
  user_data              = file("${path.module}/docker_installation.sh")


}