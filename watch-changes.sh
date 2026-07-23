#!/usr/bin/env bash
# See what OpenClaw changed on disk (Docker stores everything under ~/.openclaw on your Mac).
set -euo pipefail

WORKSPACE="${HOME}/.openclaw/workspace"
SESSIONS="${HOME}/.openclaw/agents/main/sessions"

echo "=== Workspace files (agent home) ==="
echo "Path: ${WORKSPACE}"
echo ""
if git -C "${WORKSPACE}" rev-parse --git-dir >/dev/null 2>&1; then
  git -C "${WORKSPACE}" status -sb
  echo ""
  echo "Diff vs last commit (if any):"
  git -C "${WORKSPACE}" diff --stat 2>/dev/null || true
else
  ls -la "${WORKSPACE}"
fi

echo ""
echo "=== Recently modified under ~/.openclaw (last 30 min) ==="
find "${HOME}/.openclaw" -type f -mmin -30 \
  ! -path '*/node_modules/*' \
  ! -name '*.jsonl' \
  2>/dev/null | head -40

echo ""
echo "=== Latest session trajectory (tool calls: read/write/edit/exec) ==="
LATEST=$(ls -t "${SESSIONS}"/*.trajectory.jsonl 2>/dev/null | head -1)
if [[ -n "${LATEST}" ]]; then
  echo "File: ${LATEST}"
  echo "(grep for tool names — open in editor or: tail -f \"${LATEST}\")"
  grep -E '"name":"(read|write|edit|apply_patch|exec|bash)"' "${LATEST}" 2>/dev/null | tail -15 || \
    grep -E 'write|edit|apply_patch|exec' "${LATEST}" 2>/dev/null | tail -15
else
  echo "No trajectory logs yet."
fi

echo ""
echo "=== Live gateway log (Ctrl+C to stop) ==="
echo "Run: docker exec openclaw node openclaw.mjs logs --follow --plain"
