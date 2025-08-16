# Bastion SG: Allow SSH from anywhere (or your IP)
resource "aws_security_group" "bastion_sg" {
  name        = var.bastion_sg_name
  description = "Allow SSH from public to Bastion"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from allowed CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  name        = var.private_sg_name
  description = "Allow internal node communication + SSH from Bastion"
  vpc_id      = var.vpc_id

  # SSH from Bastion
  ingress {
    description     = "SSH from Bastion SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Allow all TCP traffic between nodes in same SG
  ingress {
    description = "Allow access to Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ open to all — restrict in production
  }

  ingress {
    description = "Allow SSH between nodes in same SG"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Allow HTTP ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS for Lets Encrypt and browser"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # Allow ICMP (ping) from self
  ingress {
    description = "Allow ping (ICMP) from self"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    self        = true
  }

  # Egress: allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Bastion EIP
resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion_vm.id
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name = "bastion-eip"
  }
}

resource "aws_instance" "bastion_vm" {
  ami                                  = "ami-054b7fc3c333ac6d2"
  instance_type                        = var.instance_type
  subnet_id                            = var.public_subnet_id
  key_name                             = "gurjit-ed25519"
  vpc_security_group_ids               = [aws_security_group.bastion_sg.id]
  iam_instance_profile                 = "bastion-ssm-profile"
  disable_api_termination              = true
  instance_initiated_shutdown_behavior = "stop"

  user_data = file("${path.module}/../scripts/bastion_ssh_config.sh")

  tags = {
    Name = "bastion"
    Env  = "dev"
    Role = "ssh access"
  }
}

# Ansible EIP
resource "aws_eip" "ansible_eip" {
  instance = aws_instance.ansible_vm.id
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name = "ansible-eip"
  }
}

resource "aws_instance" "ansible_vm" {
  ami                                  = var.ami
  instance_type                        = "t2.medium"
  subnet_id                            = var.public_subnet_id
  vpc_security_group_ids               = [aws_security_group.private_sg.id]
  key_name                             = var.key_name
  private_ip                           = "10.0.1.82"
  disable_api_termination              = true
  instance_initiated_shutdown_behavior = "stop"

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = file("${path.module}/../scripts/install_ansible.sh")

  tags = {
    Name = "ansible"
    Env  = "dev"
    Role = "automation"
  }
}

# Jenkins EIP
resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.jenkins.id
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name = "jenkins-eip"
  }
}

resource "aws_instance" "jenkins" {
  ami                                  = var.ami
  instance_type                        = "t3.medium"
  subnet_id                            = var.public_subnet_id
  vpc_security_group_ids               = [aws_security_group.private_sg.id]
  key_name                             = var.key_name
  private_ip                           = "10.0.1.130"
  disable_api_termination              = true
  instance_initiated_shutdown_behavior = "stop"

  root_block_device {
    volume_size           = 50
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name        = "jenkins"
    Environment = "dev"
    Role        = "DevOps"
    Project     = "CI/CD"
  }
}

resource "aws_instance" "jenkins-agent-build-01" {
  ami                                  = var.ami
  instance_type                        = "t3.micro"
  subnet_id                            = var.public_subnet_id
  vpc_security_group_ids               = [aws_security_group.private_sg.id]
  key_name                             = var.key_name
  private_ip                           = "10.0.1.131"
  disable_api_termination              = true
  instance_initiated_shutdown_behavior = "stop"

  root_block_device {
    volume_size           = 100
    volume_type           = "gp3"
    delete_on_termination = true
  }

  #user_data = file("${path.module}/../scripts/jenkins-agent-base.sh")

  tags = {
    Name        = "jenkins-agent-build-01"
    Environment = "dev"
    Role        = "jenkins-agent"
    Owner       = "DevOps"
    Project     = "CICD"
  }
}

resource "aws_instance" "jenkins-agent-01" {
  ami                                  = var.ami
  instance_type                        = "t3.micro"
  subnet_id                            = var.public_subnet_id
  vpc_security_group_ids               = [aws_security_group.private_sg.id]
  key_name                             = var.key_name
  private_ip                           = "10.0.1.132"
  disable_api_termination              = true
  instance_initiated_shutdown_behavior = "stop"

  root_block_device {
    volume_size           = 100
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = file("${path.module}/../scripts/base_debian.sh")

  tags = {
    Name        = "jenkins-agent-build-01"
    Environment = "dev"
    Role        = "jenkins-agent"
    Owner       = "DevOps"
    Project     = "CICD"
  }
}