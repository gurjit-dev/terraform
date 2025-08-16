#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

log() { printf '[%s] %s\n' "$(date -Is)" "$*"; }

log "Refreshing package lists..."
apt-get update

log "Upgrading installed packages..."
apt-get upgrade -y

log "All set."
