output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "eks_private_subnet_ids" {
  description = "Private subnet IDs created for EKS across AZs"
  value       = aws_subnet.eks_private[*].id
}