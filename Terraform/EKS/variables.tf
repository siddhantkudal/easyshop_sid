variable "cluster_name" {
  description = "Cluster name"
}

variable "vpcid" {
  description = "vpc information to create cluster taking from ec2vpc module"
}

variable "privatesubnet" {
  description = "private subnet for nodes creation"
}

variable "intrasubnet" {
  description = "intra subnet for controlplane"
}
variable "environment" {
  description = "environment name where you want cluster "
}

variable "kubversion" {
  description = "version of kubernetes we want to deploy"
}

variable "clusterVersion" {
  description = "version of cluster we want to deploy"
}

variable "instancetype" {
  description = "Instance type of node group ex t2.medium"
}

variable "minimum_instance_count" {
  description = "instance created when we create by default in node group"
}

variable "maximum_instance_count" {
  description = "maximum instance crated when we get heavy traffic"
}

variable "desired_size" {
  description = "desired instance crated when we get heavy traffic"
}

variable "typeInstance" {
  description = "which type of instance you want spot instance, on demand instance"
}

variable "protocol" {
  description = "protocol type fpor security group"
}


variable "from_port" {
  description = "from which port in security group it should be allowed"
}

variable "to_port" {
  description = "till which port in security group it should be allowed"
}



