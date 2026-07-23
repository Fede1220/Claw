#!/usr/bin/env bash
# Update OpenClaw Docker install (pull latest image, restart).
# Control UI "Update" is for git/npm installs — use this for Docker.
set -euo pipefail
cd "$(dirname "$0")"

CONFIG_DIR="${OPENCLAW_CONFIG_DIR:-$PWD/.openclaw}"
export OPENCLAW_CONFIG_DIR="${CONFIG_DIR}"

echo "==> Pulling latest OpenClaw image..."
docker pull ghcr.io/openclaw/openclaw:latest

echo "==> Restarting gateway..."
docker compose up -d --force-recreate

sleep 5
echo ""
docker exec openclaw node openclaw.mjs --version
echo ""
echo "Done. Web UI: http://127.0.0.1:18789/"
