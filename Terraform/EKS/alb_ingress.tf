# provider "helm" {
#   kubernetes {
#     config_path = "~/.kube/config"
#   }

#   install_timeout = 600
#   upgrade_timeout = 600
# }

# resource "helm_release" "alb_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"

#   set {
#     name  = "clusterName"
#     value = var.cluster_name
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = "false"
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }

#   set {
#     name  = "region"
#     value = "us-east-1"
#   }

#   set {
#     name  = "vpcId"
#     value = var.vpcid
#   }
# }
