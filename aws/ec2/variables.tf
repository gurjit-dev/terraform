variable "ami" {
  description = "AMI ID to use"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance in"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the instances"
}

variable "bastion_ssh_cidr" {
  type        = string
  default     = "0.0.0.0/0"  # Consider limiting to your IP for prod
  description = "CIDR block to allow SSH to Bastion host"
}

variable "bastion_sg_name" {
  type        = string
  default     = "bastion-sg"
}

variable "private_sg_name" {
  type        = string
  default     = "private-sg"
}

