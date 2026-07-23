#!/usr/bin/env bash
# One-time email setup: Himalaya + Docker image with mail CLI.
set -euo pipefail
cd "$(dirname "$0")"

echo "==> Building OpenClaw image with email support..."
docker compose build

mkdir -p "${HOME}/.config/himalaya"
if [[ ! -f "${HOME}/.config/himalaya/config.toml" ]]; then
  echo "==> Creating Himalaya config template..."
  cp himalaya.config.toml.example "${HOME}/.config/himalaya/config.toml"
  echo ""
  echo "EDIT THIS FILE with your email + Gmail App Password:"
  echo "  open ~/.config/himalaya/config.toml"
  echo ""
  echo "Gmail App Password: https://myaccount.google.com/apppasswords"
  echo ""
  read -r -p "Press Enter after you have saved config.toml..."
fi

echo "==> Enabling himalaya skill in OpenClaw..."
docker compose run --rm openclaw node openclaw.mjs config set skills.entries.himalaya.enabled true

echo "==> Testing Himalaya inside container..."
docker compose run --rm openclaw himalaya envelope list --page-size 3 || {
  echo "Himalaya test failed. Check ~/.config/himalaya/config.toml"
  exit 1
}

echo ""
echo "Done. Restart: ./stop.sh && ./start.sh"
echo "Then ask JARVIS: 'List my last 3 emails' or 'Draft an email to ...'"
