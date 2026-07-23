# Windows setup (8GB laptop target)

This is the intended path: **everything on the Windows PC** — Docker OpenClaw +
local Ollama. Mac is only for editing/pushing the repo if you want.

## 1. Install on Windows

1. **Docker Desktop** (enable WSL2 when asked) → reboot if prompted → start Docker
2. **Ollama** from https://ollama.com/download → open it so the tray icon is running
3. **Git** (includes Git Bash)

Check in PowerShell:

```powershell
docker version
ollama --version
```

## 2. Clone

```powershell
cd $HOME\Projects   # or wherever you keep code
git clone <your-repo-url> Claw
cd Claw
```

## 3. Pull the model (before starting chat)

```powershell
ollama pull qwen2.5:3b-instruct
```

Fallback if 3B is too heavy with Docker open:

```powershell
ollama pull qwen2.5:1.5b-instruct
```

## 4. First-time OpenClaw setup

Use **Git Bash** in the repo folder (scripts are bash):

```bash
./setup.sh
./add-ollama.sh
```

Or from PowerShell with Git Bash:

```powershell
bash ./setup.sh
bash ./add-ollama.sh
```

If you pulled the 1.5B fallback:

```bash
OLLAMA_MODEL=qwen2.5:1.5b-instruct ./add-ollama.sh
```

## 5. Telegram

1. Create a bot with [@BotFather](https://t.me/BotFather)
2. Edit `.openclaw/.env` and set:

```env
TELEGRAM_BOT_TOKEN=123456:ABC...
OLLAMA_HOST=http://host.docker.internal:11434
```

3. Restart:

```bash
docker compose restart
```

4. Message the bot on your phone, then on the PC:

```bash
docker exec openclaw node openclaw.mjs pairing list telegram
docker exec openclaw node openclaw.mjs pairing approve telegram <CODE>
```

## 6. Web UI

```bash
./login-url.sh
```

Open http://127.0.0.1:18789/ and paste the token.

## What you are NOT giving Claw

By default this compose file:

- does **not** mount `C:\Users\...` or your Projects folder
- uses tools profile **`messaging`** (no broad shell/filesystem agent tools)
- only mounts `./.openclaw` for config + memory

That is the “Docker-like limited access” setup.

## RAM tips for GTX 1050 / 8GB

- Close Chrome tabs / heavy apps while chatting
- Prefer `qwen2.5:3b-instruct`; drop to `1.5b` if Windows starts swapping
- Context is capped at **8192** in this repo on purpose
- If you see auto-compaction / overflow errors: `./reset-chat.sh`

## Daily use

```bash
# Ollama app must be running
./start.sh
# talk on Telegram
./stop.sh
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Docker daemon not running | Start Docker Desktop, wait until it says running |
| Ollama not reachable | Open Ollama app; `curl http://127.0.0.1:11434/api/tags` |
| Context / compaction errors | `./reset-chat.sh`, keep 8k context defaults |
| UI “Auth required” | `./login-url.sh` — paste the hex token |
| Pairing required | `./approve-browser.sh` |
| Old Mac Himalaya image | This repo uses the official multi-arch image; no ARM-only layer |

## Moving secrets from Mac (optional)

Do **not** commit them. Copy privately if you want continuity:

- Mac `~/.openclaw/.env` → Windows `Claw\.openclaw\.env`
- Persona files under `workspace/` if you customized them

Fresh onboard on Windows is also fine.
