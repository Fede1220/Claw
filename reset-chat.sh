#!/usr/bin/env bash
# Reset main + Telegram chat sessions (fixes context overflow / stuck compaction).
set -euo pipefail
cd "$(dirname "$0")"

CONFIG_DIR="${OPENCLAW_CONFIG_DIR:-$PWD/.openclaw}"
export OPENCLAW_CONFIG_DIR="${CONFIG_DIR}"
SESSIONS="${CONFIG_DIR}/agents/main/sessions"
BACKUP="${SESSIONS}/backup-$(date -u +%Y%m%d-%H%M%S)"

if [[ ! -f "${SESSIONS}/sessions.json" ]]; then
  echo "No sessions store at ${SESSIONS}/sessions.json"
  exit 0
fi

mkdir -p "${BACKUP}"

python3 - "${SESSIONS}" "${BACKUP}" <<'PY'
import json, shutil, sys
from pathlib import Path

sessions_dir = Path(sys.argv[1])
backup = Path(sys.argv[2])
store_path = sessions_dir / "sessions.json"
store = json.loads(store_path.read_text())

keys = ["agent:main:main"]
keys += [k for k in store if k.startswith("agent:main:telegram:direct:")]
# Also clear webchat dashboard sessions that bloat context
keys += [k for k in store if k.startswith("agent:main:dashboard:")]

reset_any = False
for key in keys:
    entry = store.pop(key, None)
    if not entry:
        continue
    reset_any = True
    sid = entry.get("sessionId")
    if sid:
        for name in sessions_dir.glob(f"{sid}*"):
            shutil.move(str(name), str(backup / name.name))
    print(f"Reset {key} ({sid}).")
if not reset_any:
    print("No sessions to reset.")
    raise SystemExit(0)
store_path.write_text(json.dumps(store, indent=2) + "\n")
print(f"Backup: {backup}")
PY

docker compose restart
echo ""
echo "Sessions cleared. Message Telegram or open http://127.0.0.1:18789/"
