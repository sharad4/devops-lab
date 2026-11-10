#!/usr/bin/env bash
# Runs ON THE SERVER in /opt/devops-lab.  Usage: ./deploy.sh <image_tag>
# Needs /opt/devops-lab/.env with APP_KEY, DB_*, IMAGE_OWNER (see .env.example)
set -euo pipefail
TAG="${1:?usage: deploy.sh <image_tag>}"
cd /opt/devops-lab
COMPOSE="docker compose -f docker-compose.prod.yml"

PREV_TAG="$(cat .current_tag 2>/dev/null || echo '')"
echo ">> Deploying $TAG (previous: ${PREV_TAG:-none})"

export IMAGE_TAG="$TAG"
$COMPOSE pull backend frontend
$COMPOSE up -d --remove-orphans

echo ">> Waiting for health..."
for i in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:${HTTP_PORT:-80}/api/health" >/dev/null 2>&1; then
    echo "$TAG" > .current_tag
    echo ">> Healthy. Deploy OK."
    docker image prune -f >/dev/null
    exit 0
  fi
  sleep 3
done

echo "!! Health check failed."
if [ -n "$PREV_TAG" ]; then
  echo "!! Rolling back to $PREV_TAG"
  IMAGE_TAG="$PREV_TAG" $COMPOSE up -d
fi
exit 1
