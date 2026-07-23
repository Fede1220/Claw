# Claw — OpenClaw Project Context

> **Purpose:** Architecture, config, and migration notes for this setup.  
> **Owner:** Fede  
> **Last updated:** July 2026

---

## What this project is

A **personal AI assistant (J.A.R.V.I.S.)** on [OpenClaw](https://docs.openclaw.ai),
running in **Docker**, reachable from **Telegram**, powered by **local Ollama**.

**Current target host:** Windows 11 laptop (8GB RAM, GTX 1050 3GB)  
**Current model:** `ollama/qwen2.5:3b-instruct` (fallback: `qwen2.5:1.5b-instruct`)

Goals:

- Free local inference (no paid API required)
- Telegram as the main chat surface
- Limited host access (config dir mount only — not full disk)
- Avoid context-overflow / fake “rate limit” failures on small models

---

## Architecture (Windows-first)

```text
┌─────────────────────────────────────────────────────────────┐
│  Windows PC (keep awake for bot)                            │
│                                                             │
│  ┌──────────────┐      host.docker.internal:11434          │
│  │ Ollama       │◄─────────────────────────────┐           │
│  │ qwen2.5:3b-  │                               │           │
│  │ instruct     │                               │           │
│  └──────────────┘                               │           │
│                                                 │           │
│  ┌──────────────────────────────────────────────┴─────────┐ │
│  │ Docker: openclaw (ghcr.io/openclaw/openclaw:latest)    │ │
│  │  • Gateway :18789                                      │ │
│  │  • tools.profile: messaging                            │ │
│  │  • volume: ./.openclaw only                            │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
            │
     Internet / Telegram
```

---

## Repo vs local state

| Path | What |
|------|------|
| This GitHub repo | Scripts, compose, docs, examples |
| `./.openclaw/` (gitignored) | Real config, `.env`, sessions, memory |

**Never commit:** Telegram token, gateway token, session transcripts.

---

## Lean defaults (anti-overflow)

| Setting | Value | Why |
|---------|--------|-----|
| `contextWindow` / `num_ctx` | `8192` | Fits 8GB + Docker |
| `bootstrapMaxChars` | `800` | Stops AGENTS/SOUL from eating the window |
| `reserveTokensFloor` | `2000` | Must stay << context (20k on 8k context breaks chat) |
| `maxTokens` | `1024` | Leaves room for prompt |
| `tools.profile` | `messaging` | Smaller tool schemas in the prompt |
| Host mounts | config only | No Projects / home disk access |

These “limit” errors on Mac were **context overflows**, not cloud rate limits.

---

## Daily commands

See `Cheatsheet.txt` and `WINDOWS.md`.

```bash
./setup.sh && ./add-ollama.sh
./start.sh
./reset-chat.sh   # if compaction / overflow returns
./stop.sh
```

---

## Security

- Gateway token = password
- Telegram pairing + owner allowlist
- No full filesystem mount by default
- Himalaya/email skill disabled

---

## Links

- [OpenClaw docs](https://docs.openclaw.ai)
- [OpenClaw Docker](https://docs.openclaw.ai/install/docker)
- [Ollama](https://ollama.com)
- [Qwen2.5 on Ollama](https://ollama.com/library/qwen2.5)
