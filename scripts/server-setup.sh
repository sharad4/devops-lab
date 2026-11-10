#!/usr/bin/env bash
# One-time prep of an Ubuntu VM (staging/prod). Run as root.
set -euo pipefail
apt-get update && apt-get install -y ca-certificates curl
curl -fsSL https://get.docker.com | sh
id deploy &>/dev/null || adduser --disabled-password --gecos "" deploy
usermod -aG docker deploy
mkdir -p /opt/devops-lab && chown deploy:deploy /opt/devops-lab
echo ">> Now: put your public deploy key in /home/deploy/.ssh/authorized_keys"
echo ">> Create /opt/devops-lab/.env (see .env.example) and 'docker login ghcr.io' as deploy user (PAT with read:packages)."
