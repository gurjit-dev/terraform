#!/bin/bash
set -e

# Retry wrapper
retry() {
  for i in {1..3}; do
    "$@" && break || sleep 5
  done
}

# Install Ansible on Ubuntu 24.04
retry apt update -y
retry apt upgrade -y
retry apt install -y software-properties-common
retry add-apt-repository --yes --update ppa:ansible/ansible
retry apt install -y ansible git curl unzip python3-pip

# Create working directory
mkdir -p /opt
sudo chown ubuntu:ubuntu /opt/ -R
sudo git clone https://github.com/gurjit-dev/ansible.git /opt/ansible

# Write SSH config
chown ubuntu:ubuntu /home/ubuntu/.ssh/ -R
touch /home/ubuntu/.ssh/ansible_key
cat <<EOF > /home/ubuntu/.ssh/config
Host *
  IdentityFile ~/.ssh/ansible_key
  IdentitiesOnly yes
  User ubuntu
EOF


