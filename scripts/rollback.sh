#!/usr/bin/env bash
# Manual rollback on the server: ./rollback.sh <known_good_tag>
set -euo pipefail
cd /opt/devops-lab
export IMAGE_TAG="${1:?usage: rollback.sh <tag>}"
docker compose -f docker-compose.prod.yml up -d
echo "$IMAGE_TAG" > .current_tag
curl -fsS "http://127.0.0.1:${HTTP_PORT:-80}/api/health" && echo " rolled back to $IMAGE_TAG"
