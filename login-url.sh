#!/usr/bin/env bash
# Print the gateway token for the Control UI.
set -euo pipefail
cd "$(dirname "$0")"

CONFIG="${OPENCLAW_CONFIG_DIR:-$PWD/.openclaw}/openclaw.json"

if [[ ! -f "${CONFIG}" ]]; then
  echo "No config at ${CONFIG}. Run ./setup.sh first."
  exit 1
fi

python3 - "${CONFIG}" <<'PY'
import json, pathlib, sys
p = pathlib.Path(sys.argv[1])
c = json.loads(p.read_text())
token = c.get("gateway", {}).get("auth", {}).get("token", "")
if not token:
    print("No token in config. Run:")
    print("  docker exec openclaw node openclaw.mjs doctor --generate-gateway-token")
    print("  docker compose restart")
    raise SystemExit(1)

print("=" * 60)
print("IMPORTANT: The website label OPENCLAW_GATEWAY_TOKEN is a HINT.")
print("Do NOT type that text. Paste the actual token below:")
print("=" * 60)
print()
print(token)
print()
print("Steps:")
print("  1. Open http://127.0.0.1:18789/")
print("  2. Paste the token above into the Gateway token field")
print("  3. Click Connect")
print("  4. If you see 'pairing required', run: ./approve-browser.sh")
print()
print("Or open this URL (token in the link):")
print(f"http://127.0.0.1:18789/#token={token}")
PY
