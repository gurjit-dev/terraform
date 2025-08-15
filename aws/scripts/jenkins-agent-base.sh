#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

log() { echo "[$(date -Is)] $*"; }

log "apt update/upgrade"
apt-get update -y
apt-get upgrade -y

log "Base tools"
apt-get install -y \
  openjdk-17-jre-headless \
  git curl unzip jq ca-certificates \
  gnupg lsb-release \
  awscli \
  docker.io

systemctl enable --now docker

log "kubectl 1.33.x"
ARCH="$(dpkg --print-architecture)"   # amd64 or arm64
KVER="v1.33.1"
curl -fsSL -o /usr/local/bin/kubectl \
  "https://dl.k8s.io/release/${KVER}/bin/linux/${ARCH}/kubectl"
chmod +x /usr/local/bin/kubectl

log "Create jenkins user and add to docker"
id -u jenkins >/dev/null 2>&1 || useradd -m -s /bin/bash jenkins
usermod -aG docker jenkins
install -o jenkins -g jenkins -m 700 -d /home/jenkins
install -o jenkins -g jenkins -m 700 -d /home/jenkins/bin

log "Fetch Jenkins agent.jar from your controller"
curl -fsSLo /home/jenkins/bin/agent.jar https://jenkins.gangars.com/jnlpJars/agent.jar
chown jenkins:jenkins /home/jenkins/bin/agent.jar

log "Agent connection settings (fill in AGENT_NAME/AGENT_SECRET)"
cat >/etc/jenkins-agent.env <<'EOF'
JENKINS_URL=https://jenkins.gangars.com
AGENT_NAME=build-agent-01              # <-- set this to your node name
AGENT_SECRET=REPLACE_ME                # <-- paste the secret from the node page
WORK_DIR=/home/jenkins
EOF
chmod 600 /etc/jenkins-agent.env

log "Systemd service for inbound (WebSocket) agent"
cat >/etc/systemd/system/jenkins-agent.service <<'EOF'
[Unit]
Description=Jenkins Inbound Agent
After=network-online.target
Wants=network-online.target

[Service]
User=jenkins
Group=jenkins
EnvironmentFile=/etc/jenkins-agent.env
WorkingDirectory=%h
ExecStart=/usr/bin/java -jar %h/bin/agent.jar \
  -jnlpUrl ${JENKINS_URL}/computer/${AGENT_NAME}/jenkins-agent.jnlp \
  -secret ${AGENT_SECRET} \
  -workDir ${WORK_DIR} \
  -webSocket
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now jenkins-agent

log "Docker log tuning (optional)"
mkdir -p /etc/docker
cat >/etc/docker/daemon.json <<'JSON'
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "3" }
}
JSON
systemctl restart docker || true

log "Done. Quick checks:"
sudo -u jenkins -H bash -lc 'java -version || true; test -f ~/bin/agent.jar && echo agent.jar OK || echo agent.jar MISSING'
