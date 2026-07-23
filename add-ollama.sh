#!/usr/bin/env bash
# Configure OpenClaw → local Ollama (optimized for 8GB hosts + Qwen 3B).
#
# Defaults tuned to avoid the old context-overflow / auto-compaction failures:
#   - contextWindow / num_ctx: 8192 (not 12k+)
#   - bootstrapMaxChars: 800
#   - reserveTokensFloor: 2000  (must stay well below half of context)
#   - tools.profile: messaging (lean prompt)
#
# Prerequisites on the HOST (outside Docker):
#   1. Install Ollama: https://ollama.com/download
#   2. Start Ollama (Windows tray / Mac app / `ollama serve`)
#   3. Pull once: ollama pull qwen2.5:3b-instruct
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${OPENCLAW_CONFIG_DIR:-$SCRIPT_DIR/.openclaw}"
IMAGE="ghcr.io/openclaw/openclaw:latest"
OLLAMA_BASE_URL="${OLLAMA_BASE_URL:-http://host.docker.internal:11434}"
OLLAMA_CHECK_URL="${OLLAMA_CHECK_URL:-http://127.0.0.1:11434}"
OLLAMA_MODEL="${OLLAMA_MODEL:-qwen2.5:3b-instruct}"
OLLAMA_BASE_MODEL="${OLLAMA_BASE_MODEL:-qwen2.5:3b}"
NUM_CTX="${NUM_CTX:-8192}"

run_cfg() {
  docker run --rm -v "${CONFIG_DIR}:/home/node/.openclaw" "${IMAGE}" \
    node openclaw.mjs config set "$@"
}

mkdir -p "${CONFIG_DIR}"

echo "==> Checking Ollama on host (${OLLAMA_CHECK_URL})..."
if ! curl -sf "${OLLAMA_CHECK_URL%/}/api/tags" >/dev/null 2>&1; then
  echo "Ollama is not reachable at ${OLLAMA_CHECK_URL}."
  echo "Start Ollama, then re-run this script."
  echo "  Windows: open the Ollama app from the Start menu"
  echo "  Mac:     open -a Ollama   OR   ollama serve"
  echo "  Pull:    ollama pull ${OLLAMA_MODEL}"
  exit 1
fi
echo "    OK (Docker will use ${OLLAMA_BASE_URL})"

echo "==> Ensuring model exists (${OLLAMA_MODEL}, num_ctx=${NUM_CTX})..."
if command -v ollama >/dev/null 2>&1; then
  # Prefer official instruct tag when present; else build a thin Modelfile.
  if ! ollama show "${OLLAMA_MODEL}" >/dev/null 2>&1; then
    if ollama show "${OLLAMA_BASE_MODEL}" >/dev/null 2>&1 || ollama pull "${OLLAMA_BASE_MODEL}"; then
      TMP_MODELFILE="$(mktemp 2>/dev/null || mktemp -t openclaw)"
      cat > "${TMP_MODELFILE}" <<EOF
FROM ${OLLAMA_BASE_MODEL}
PARAMETER num_ctx ${NUM_CTX}
EOF
      ollama create "${OLLAMA_MODEL}" -f "${TMP_MODELFILE}"
      rm -f "${TMP_MODELFILE}"
    else
      echo "Could not pull ${OLLAMA_BASE_MODEL}. Run: ollama pull ${OLLAMA_MODEL}"
      exit 1
    fi
  fi
else
  echo "WARN: 'ollama' CLI not on PATH. Assuming ${OLLAMA_MODEL} is already pulled."
fi

echo "==> Configuring OpenClaw for Ollama (${OLLAMA_MODEL})..."
docker run --rm \
  -v "${CONFIG_DIR}:/home/node/.openclaw" \
  "${IMAGE}" \
  node openclaw.mjs onboard \
    --non-interactive \
    --accept-risk \
    --mode local \
    --no-install-daemon \
    --auth-choice ollama \
    --custom-base-url "${OLLAMA_BASE_URL}" \
    --custom-model-id "${OLLAMA_MODEL}" \
    --skip-health

run_cfg agents.defaults.model.primary "ollama/${OLLAMA_MODEL}"
run_cfg gateway.bind lan
run_cfg tools.profile messaging
run_cfg agents.defaults.thinkingDefault off
run_cfg agents.defaults.heartbeat.every 0m
run_cfg agents.defaults.bootstrapMaxChars 800
run_cfg agents.defaults.compaction.reserveTokensFloor 2000
run_cfg plugins.entries.google.enabled false
run_cfg plugins.entries.ollama.enabled true
run_cfg models.providers.ollama.models "$(cat <<JSON
[
  {
    "id": "${OLLAMA_MODEL}",
    "name": "${OLLAMA_MODEL}",
    "reasoning": false,
    "input": ["text"],
    "cost": {
      "input": 0,
      "output": 0,
      "cacheRead": 0,
      "cacheWrite": 0
    },
    "contextWindow": ${NUM_CTX},
    "maxTokens": 1024,
    "compat": {
      "supportsTools": true,
      "supportsUsageInStreaming": true
    }
  }
]
JSON
)" --strict-json --replace

ENV_FILE="${CONFIG_DIR}/.env"
touch "${ENV_FILE}"
if ! grep -q '^OLLAMA_HOST=' "${ENV_FILE}" 2>/dev/null; then
  echo "OLLAMA_HOST=${OLLAMA_BASE_URL}" >> "${ENV_FILE}"
fi

cd "${SCRIPT_DIR}"
export OPENCLAW_CONFIG_DIR="${CONFIG_DIR}"
docker compose up -d
docker compose restart

echo ""
echo "Ollama configured (lean / 8GB-friendly)."
echo "  Model:   ollama/${OLLAMA_MODEL}"
echo "  Context: ${NUM_CTX}"
echo "  Config:  ${CONFIG_DIR}"
echo "  Web UI:  http://127.0.0.1:18789/"
echo ""
echo "If chat still overflows: ./reset-chat.sh"
echo "If still tight on RAM:   OLLAMA_MODEL=qwen2.5:1.5b-instruct ./add-ollama.sh"
