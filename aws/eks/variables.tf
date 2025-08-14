variable "name" {
  description = "EKS cluster name"
  type        = string
  default     = "dev-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.33"
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}

variable "eks_private_subnet_ids" {
  description = "List of private subnet IDs for EKS"
  type        = list(string)
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}
