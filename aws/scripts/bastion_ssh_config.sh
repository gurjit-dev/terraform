#!/bin/bash

mkdir -p /home/ec2-user/.ssh

# Download key from SSM Parameter Store
for i in {1..3}; do
  aws ssm get-parameter \
    --name "/infra/infra-ssh-key" \
    --with-decryption \
    --region us-west-2 \
    --query "Parameter.Value" \
    --output text > /home/ec2-user/.ssh/infra-ssh-key.pem && break
  sleep 5
done

chown ec2-user:ec2-user /home/ec2-user/.ssh/infra-ssh-key.pem
chmod 400 /home/ec2-user/.ssh/infra-ssh-key.pem

# Write SSH config
cat <<EOF > /home/ec2-user/.ssh/config
Host *
  IdentityFile ~/.ssh/infra-ssh-key.pem
  IdentitiesOnly yes
EOF

chown ec2-user:ec2-user /home/ec2-user/.ssh/config
chmod 600 /home/ec2-user/.ssh/config