output "bastion_instance_profile" {
  description = "IAM Instance Profile to attach to Bastion Host"
  value       = aws_iam_instance_profile.bastion_profile.name
}
