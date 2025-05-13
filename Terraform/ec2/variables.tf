variable "region" {
  description = "Region if AWS"

}

variable "cidr_vpc" {
  description = "cidr block fot VPC"
}

variable "application" {
  description = "Environmrnt Application name"
  default     = "EasyShop"
}

variable "public_subnet1_cidr" {
  description = "cidr block fot public_subnet1"
}

variable "private_subnet1_cidr" {
  description = "cidr block fot private_subnet1"
}

variable "instance_image" {
  description = "image id"
}

variable "instance_type" {
  description = "instance type"
}
variable "instance_count" {
  description = "instance count"

}
variable "cidr_block_internet_access" {
  description = "cidr block 0.0.0.0 for all access"
}
