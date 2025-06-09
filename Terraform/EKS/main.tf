module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"
  #cluster information (control plane)
  cluster_name                   = var.cluster_name
  cluster_version                = var.clusterVersion #"1.31"
  cluster_endpoint_public_access = true
  vpc_id                         = var.vpcid
  subnet_ids                     = var.privatesubnet
  enable_irsa = true
  #we are using intra subnet for control plane to create the API server inside VPC so that in public it is not accessible
  #intra subnet is used when servies inside vpc need to connect with each other here internet is not provide for intra subnet 
  control_plane_subnet_ids = var.intrasubnet


  #Cluster information (control plane)
  cluster_addons = {
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
  }

  #managing nodes in cluster
  eks_managed_node_group_defaults = {

    instance_types                        = [var.instancetype]
    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    sgk-node-group = {
      instance_types = [var.instancetype]
      min_size       = var.minimum_instance_count
      max_size       = var.maximum_instance_count
      desired_size   = var.desired_size
      iam_role_arn   = aws_iam_role.eks_node_role.arn
      capacity_type  = var.typeInstance

    }
  }
  #this security group attached to worker node so they can connect to contol plane
  node_security_group_additional_rules = {
    ingress_allow_control_plane = {
      description                   = "Allow control plane to communicate with worker nodes"
      protocol                      = var.protocol
      from_port                     = var.from_port
      to_port                       = var.to_port
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }


  tags = {
    Environment = var.environment
    Terraform   = "true"
  }

}




module "alb_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix = "alb-controller"
  #cluster_name     = var.cluster_name
  attach_load_balancer_controller_policy = true
  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = {
    Environment = var.environment
  }
}


#this policy need to attach to cluster so they can access the nodes 
resource "aws_iam_role" "EKS_cluster_role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}
#This policy attached to above role 
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.EKS_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.EKS_cluster_role.name
}

#this policy need to attach to Nodes so they can connect to the control plane  

resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}


resource "aws_iam_role_policy_attachment" "ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

data "http" "alb_ingress_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "alb_ingress_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy1"
  policy = data.http.alb_ingress_policy.body
} 

resource "aws_iam_role_policy_attachment" "alb_policy_attach" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = aws_iam_policy.alb_ingress_policy.arn
}



resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.cluster_name}-eks-cluster-sg"
  description = "Allow EKS control plane to communicate with worker nodes"
  vpc_id      = var.vpcid

  ingress {
    description = "K8s API server"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NodePort range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NodePort range"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

