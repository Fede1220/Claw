#!/usr/bin/env bash
# First-time setup: create ./.openclaw and start the gateway.
set -euo pipefail
cd "$(dirname "$0")"

IMAGE="ghcr.io/openclaw/openclaw:latest"
CONFIG_DIR="${OPENCLAW_CONFIG_DIR:-$PWD/.openclaw}"
export OPENCLAW_CONFIG_DIR="${CONFIG_DIR}"

run_cli() {
  docker run --rm \
    -v "${CONFIG_DIR}:/home/node/.openclaw" \
    "${IMAGE}" \
    node openclaw.mjs "$@"
}

echo "==> Ensuring config directory: ${CONFIG_DIR}"
mkdir -p "${CONFIG_DIR}"

if [[ ! -f "${CONFIG_DIR}/.env" ]]; then
  cp .env.example "${CONFIG_DIR}/.env"
  echo "Created ${CONFIG_DIR}/.env — add TELEGRAM_BOT_TOKEN before Telegram use."
fi

if [[ ! -f "${CONFIG_DIR}/openclaw.json" ]]; then
  echo "==> First-time onboard..."
  run_cli onboard \
    --non-interactive \
    --accept-risk \
    --mode local \
    --no-install-daemon \
    --auth-choice skip \
    --flow quickstart \
    --skip-health

  echo "==> Applying lean defaults..."
  run_cli config set gateway.bind lan
  run_cli config set gateway.controlUi.allowedOrigins \
    '["http://localhost:18789","http://127.0.0.1:18789"]' \
    --strict-json
  run_cli config set tools.profile messaging
  run_cli config set agents.defaults.thinkingDefault off
  run_cli config set agents.defaults.heartbeat.every 0m
  run_cli config set agents.defaults.bootstrapMaxChars 800
  run_cli config set agents.defaults.compaction.reserveTokensFloor 2000
else
  echo "==> Config already exists, skipping onboard."
fi

echo "==> Starting gateway..."
docker rm -f openclaw 2>/dev/null || true
docker compose up -d

echo ""
echo "Gateway starting on http://127.0.0.1:18789"
echo ""
echo "Next:"
echo "  1. Start Ollama on the host and pull the model:"
echo "       ollama pull qwen2.5:3b-instruct"
echo "  2. Wire OpenClaw to Ollama:"
echo "       ./add-ollama.sh"
echo "  3. Put TELEGRAM_BOT_TOKEN in ${CONFIG_DIR}/.env then restart:"
echo "       docker compose restart"
echo "  4. Pair Telegram if needed:"
echo "       docker exec openclaw node openclaw.mjs pairing list telegram"
echo ""
echo "Windows users: see WINDOWS.md"
