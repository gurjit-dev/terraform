provider "aws" {
  region = var.region
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.name
  kubernetes_version = var.kubernetes_version
  vpc_id             = var.vpc_id
  subnet_ids         = var.eks_private_subnet_ids

  enable_cluster_creator_admin_permissions = true
  endpoint_public_access                   = true

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Role        = "k8s"
  }
}
