# Claw — OpenClaw (Docker) + local Ollama

Personal Telegram/web assistant (JARVIS), optimized for an **8GB Windows laptop**
running **Ollama `qwen2.5:3b-instruct`** next to Docker.

## What this repo is

Clone-and-run Docker scripts + docs. **Secrets and chat memory stay local** in
`./.openclaw/` (gitignored).

```text
Telegram / Web UI
       │
       ▼
Docker: OpenClaw (gateway :18789)   ← lean tools, no full-disk mount
       │
       ▼
Host Ollama (:11434)                ← qwen2.5:3b-instruct
```

## Realistic on Windows?

Yes, if you install:

1. [Docker Desktop](https://www.docker.com/products/docker-desktop/) (WSL2 backend)
2. [Ollama for Windows](https://ollama.com/download)
3. Git

Then clone this repo and follow [WINDOWS.md](WINDOWS.md).

## Quick start (Mac / Linux / Git Bash)

```bash
git clone <your-repo-url> Claw
cd Claw
./setup.sh
ollama pull qwen2.5:3b-instruct
./add-ollama.sh
# edit .openclaw/.env → TELEGRAM_BOT_TOKEN=...
docker compose restart
```

## Why the old “limit” errors happened

Those were **local context overflows**, not paid API rate limits. This repo’s
defaults avoid that on small models:

| Setting | Value |
|---------|--------|
| Model | `qwen2.5:3b-instruct` |
| Context | `8192` |
| `bootstrapMaxChars` | `800` |
| `reserveTokensFloor` | `2000` |
| Tools | `messaging` only |
| Host mounts | **config dir only** (no Projects folder) |

If chat still overflows: `./reset-chat.sh`  
If RAM is still tight: `OLLAMA_MODEL=qwen2.5:1.5b-instruct ./add-ollama.sh`

## Security posture (“Docker-like, not full access”)

- OpenClaw only sees `./.openclaw` inside the container
- No whole-user / Projects volume mount by default
- Email skill off; Google plugin off
- Keep secrets in `.openclaw/.env` — never commit them

## Docs

- [WINDOWS.md](WINDOWS.md) — Windows clone checklist
- [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) — architecture notes
- [Cheatsheet.txt](Cheatsheet.txt) — common commands
- [openclaw.example.json](openclaw.example.json) — example config (no secrets)

## Commands

| Script | Purpose |
|--------|---------|
| `./setup.sh` | First-time config + start |
| `./add-ollama.sh` | Point at local Qwen via Ollama |
| `./start.sh` / `./stop.sh` | Start / stop gateway |
| `./reset-chat.sh` | Clear bloated sessions |
| `./update.sh` | Pull latest OpenClaw image |
| `./login-url.sh` | Print Control UI token |
