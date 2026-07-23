# Optional PowerShell helpers for Windows (Git Bash still recommended for ./scripts).
# Usage (from repo root):
#   .\setup-windows.ps1

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Write-Host "==> Checking Docker..."
docker version | Out-Null

Write-Host "==> Checking Ollama..."
try {
  Invoke-WebRequest -Uri "http://127.0.0.1:11434/api/tags" -UseBasicParsing | Out-Null
} catch {
  Write-Host "Ollama is not reachable. Start the Ollama app, then re-run."
  Write-Host "Pull model: ollama pull qwen2.5:3b-instruct"
  exit 1
}

Write-Host "==> Pulling model (if needed)..."
ollama pull qwen2.5:3b-instruct

$bash = $null
foreach ($cand in @(
  "C:\Program Files\Git\bin\bash.exe",
  "C:\Program Files (x86)\Git\bin\bash.exe"
)) {
  if (Test-Path $cand) { $bash = $cand; break }
}
if (-not $bash) {
  Write-Host "Git Bash not found. Install Git for Windows, then run:"
  Write-Host "  bash ./setup.sh"
  Write-Host "  bash ./add-ollama.sh"
  exit 1
}

Write-Host "==> Running setup.sh ..."
& $bash ./setup.sh
Write-Host "==> Running add-ollama.sh ..."
& $bash ./add-ollama.sh

Write-Host ""
Write-Host "Done. Next:"
Write-Host "  1. Edit .openclaw\.env and set TELEGRAM_BOT_TOKEN"
Write-Host "  2. docker compose restart"
Write-Host "  3. Pair Telegram (see WINDOWS.md)"
Write-Host "  4. Web UI: http://127.0.0.1:18789/  (bash ./login-url.sh)"
