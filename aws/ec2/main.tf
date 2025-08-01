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

# Private SG: Allow SSH only from Bastion
resource "aws_security_group" "private_sg" {
  name        = var.private_sg_name
  description = "Allow SSH from Bastion only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from Bastion SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "bastion_vm" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = "gurjit-ed25519"
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "bastion"
    Env  = "dev"
    Role = "ssh access"
  }
}

resource "aws_instance" "ansible_vm" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.private_sg.id] # reuse the same SG
  key_name               = var.key_name

  associate_public_ip_address = false # Ansible VM is private

  tags = {
    Name = "ansible"
    Env  = "dev"
    Role = "automation"
  }
}
