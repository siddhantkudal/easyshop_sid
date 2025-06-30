provider "aws" {
  region = "ap-south-1"
}

module "EC2vpc" {
  source                     = "./ec2"
  region                     = "ap-south-1"
  cidr_vpc                   = "10.0.0.0/16"
  application                = "EasyShop"
  public_subnet1_cidr        = "10.0.1.0/24"
  public_subnet2_cidr        = "10.0.2.0/24"
  private_subnet1_cidr       = "10.0.3.0/24"
  private_subnet2_cidr       = "10.0.4.0/24"
  intrasubnet1_cidr          = "10.0.5.0/24"
  intrasubnet2_cidr          = "10.0.6.0/24"
  instance_count             = 1
  #instance_image             = #"ami-0866a3c8686eaeeba"
  instance_image                       = "ami-02521d90e7410d9f0"
  instance_type              = "t2.medium"
  cidr_block_internet_access = "0.0.0.0/0"
  cluster_name               = "sgk-eks-cluster"
}



# module "eks" {
#   source                 = "./EKS"
#   cluster_name           = "sgk-eks-cluster"
#   vpcid                  = module.EC2vpc.vpcId
#   privatesubnet          = [module.EC2vpc.privatesubnetid1, module.EC2vpc.privatesubnetid2]
#   intrasubnet            = [module.EC2vpc.intrasubnetid1, module.EC2vpc.intrasubnetid2]
#   environment            = "DEV"
#   kubversion             = "19.15.1"
#   clusterVersion         = "1.31"
#   instancetype           = "t2.medium"
#   minimum_instance_count = "2"
#   maximum_instance_count = "2"
#   desired_size           = "2"
#   typeInstance           = "ON_DEMAND"
#   protocol               = "tcp"
#   from_port              = "1025"
#   to_port                = "65535"

# }