# J.A.R.V.I.S. personality (source of truth)

OpenClaw loads **`~/.openclaw/workspace/SOUL.md`** into the system prompt at the start of each conversation (Telegram, web UI, TUI).

After editing `SOUL.md`, reset sessions so the bot picks up the new personality:

```bash
cd ~/Projects/Claw
./reset-chat.sh
```

Operational rules (email, destructive actions, Telegram-first) stay in **`JARVIS.md`**.
