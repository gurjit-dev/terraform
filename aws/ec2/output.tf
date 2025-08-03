output "bastion_instance_id" {
  value = aws_instance.bastion_vm.id
}

output "bastion_public_ip" {
  value = aws_instance.bastion_vm.public_ip
}

output "ansible_instance_id" {
  value = aws_instance.ansible_vm.id
}

output "ansible_private_ip" {
  value = aws_instance.ansible_vm.private_ip
}

output "jenkins_instance_id" {
  value = aws_instance.jenkins.id
}

output "jenkins_private_ip" {
  value = aws_instance.jenkins.private_ip
}