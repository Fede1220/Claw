#!/usr/bin/env bash
# Start OpenClaw gateway (Docker).
set -euo pipefail
cd "$(dirname "$0")"

CONFIG_DIR="${OPENCLAW_CONFIG_DIR:-$PWD/.openclaw}"
export OPENCLAW_CONFIG_DIR="${CONFIG_DIR}"

if [[ ! -f "${CONFIG_DIR}/openclaw.json" ]]; then
  echo "No config yet. Run ./setup.sh first."
  exit 1
fi

docker compose up -d
echo ""
echo "OpenClaw is running."
echo "  Config:  ${CONFIG_DIR}"
echo "  Web UI:  http://127.0.0.1:18789/"
echo "  Token:   ./login-url.sh"
echo "  Stop:    ./stop.sh"
