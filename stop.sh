#!/usr/bin/env bash
# Stop OpenClaw gateway (keeps config in ./.openclaw).
set -euo pipefail
cd "$(dirname "$0")"

CONFIG_DIR="${OPENCLAW_CONFIG_DIR:-$PWD/.openclaw}"
export OPENCLAW_CONFIG_DIR="${CONFIG_DIR}"

docker compose down
echo "OpenClaw stopped. Config kept in ${CONFIG_DIR}"
