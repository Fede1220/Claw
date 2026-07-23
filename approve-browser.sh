#!/usr/bin/env bash
# Approve your browser so the Control UI can connect (run after pasting the gateway token).
set -euo pipefail

echo "Pending devices:"
docker exec openclaw node openclaw.mjs devices list

echo ""
read -r -p "Paste the Request ID to approve (or press Enter to approve the first pending): " REQ_ID

if [[ -z "${REQ_ID}" ]]; then
  REQ_ID=$(docker exec openclaw node openclaw.mjs devices list 2>&1 | grep -oE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' | head -1)
fi

if [[ -z "${REQ_ID}" ]]; then
  echo "No pending request found. Refresh http://127.0.0.1:18789/ and try Connect again."
  exit 1
fi

docker exec openclaw node openclaw.mjs devices approve "${REQ_ID}"
echo "Approved. Refresh the browser and click Connect again."
