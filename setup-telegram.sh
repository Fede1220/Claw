#!/usr/bin/env bash
# Connect OpenClaw to YOU via Telegram (bot messages you on your phone).
# You do NOT need email or Himalaya for this.
set -euo pipefail
cd "$(dirname "$0")"

if [[ -z "${TELEGRAM_BOT_TOKEN:-}" ]]; then
  echo "Get a bot token from Telegram @BotFather:"
  echo "  1. Open Telegram, search @BotFather"
  echo "  2. Send /newbot and follow prompts"
  echo "  3. Copy the token (looks like 123456789:ABCdef...)"
  echo ""
  read -r -p "Paste your bot token here: " TELEGRAM_BOT_TOKEN
fi

if [[ -z "${TELEGRAM_BOT_TOKEN}" ]]; then
  echo "No token provided."
  exit 1
fi

echo "==> Saving token to ~/.openclaw/.env"
touch "${HOME}/.openclaw/.env"
if grep -q '^TELEGRAM_BOT_TOKEN=' "${HOME}/.openclaw/.env" 2>/dev/null; then
  sed -i.bak "s|^TELEGRAM_BOT_TOKEN=.*|TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}|" "${HOME}/.openclaw/.env"
else
  echo "TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}" >> "${HOME}/.openclaw/.env"
fi

echo "==> Enabling Telegram in OpenClaw config..."
docker compose run --rm \
  -e "TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}" \
  openclaw node openclaw.mjs config set channels.telegram.enabled true

docker compose run --rm \
  -e "TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}" \
  openclaw node openclaw.mjs config set channels.telegram.dmPolicy pairing

echo "==> Restarting gateway..."
docker compose down 2>/dev/null || true
docker rm -f openclaw 2>/dev/null || true
docker compose up -d

sleep 5
echo ""
echo "=== Next steps on your phone ==="
echo "1. Open Telegram and find YOUR new bot (name you gave BotFather)"
echo "2. Send it any message (e.g. hi)"
echo "3. On your Mac, approve the pairing:"
echo "     docker exec openclaw node openclaw.mjs pairing list telegram"
echo "     docker exec openclaw node openclaw.mjs pairing approve telegram <CODE>"
echo ""
echo "Then chat with JARVIS in that Telegram DM."
