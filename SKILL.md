---
name: gateway-notify
version: 2.1.4
description: "Set up automatic notifications when OpenClaw gateway restarts. Use when user wants to be notified of gateway startup events via any messaging channel (iMessage, WhatsApp, Telegram, Discord, etc.)."
permissions:
  - shell_exec      # runs setup_gateway_notify.sh to create hook files
  - file_write      # writes hook handler under ~/.openclaw/hooks/
  - hook_install    # registers a persistent gateway:startup hook
  - network_send    # hook sends outbound notification on every gateway startup
  - gateway_restart # restarts the gateway to activate the hook
---

# Gateway Notify

Send a notification (with user confirmation) when the OpenClaw gateway starts up.

## What It Does

Creates a hook that triggers on `gateway:startup` events and sends a minimal notification (startup timestamp only) to the user's preferred channel.

> **Privacy notice:** This hook auto-runs on every gateway startup and sends a message to your chosen messaging channel. Only the startup timestamp is transmitted — no local configuration, model names, or network details leave your machine.

## Quick Start

> ⚠️ **Before running setup, confirm with the user:**
> 1. The setup script will execute shell commands and write files under `~/.openclaw/hooks/`.
> 2. It will restart the gateway — **this will briefly disconnect the current session** (requires manual reconnect if auto-reconnect is unavailable).
> 3. On every subsequent gateway startup, a notification will be sent automatically to the specified messaging channel. Only the startup timestamp is transmitted — no model names, API keys, or local paths leave your machine. Note: the message passes through the third-party channel's servers, which may log message metadata (send time, sender).
> 4. **To uninstall:** run `scripts/uninstall_gateway_notify.sh` or delete `~/.openclaw/hooks/gateway-restart-notify/` and restart the gateway. Deleting the skill alone does NOT stop the hook.
>
> Ask the user to confirm they accept these actions before proceeding.

Run the setup script with the user's messaging channel and address:

```bash
scripts/setup_gateway_notify.sh <channel> <address>
```

Examples:
```bash
scripts/setup_gateway_notify.sh imessage user@example.com
scripts/setup_gateway_notify.sh whatsapp +1234567890
scripts/setup_gateway_notify.sh telegram @username
```

The script will (requires user confirmation before execution):
1. Create the hook directory at `~/.openclaw/hooks/gateway-restart-notify`
2. Generate the handler with the specified channel configuration (with security hardening)
3. Restart the gateway to activate — **this will briefly disconnect the current session** (OpenClaw 2026.7+ auto-loads hooks, no explicit enable needed)

## How It Works

The hook uses OpenClaw's internal hook system:
- Listens for `gateway:startup` events
- Collects gateway startup time
- Sends notification via the configured channel CLI

## Supported Channels

See [CHANNELS.md](references/CHANNELS.md) for channel-specific CLI commands and address formats.

## Requirements

- OpenClaw gateway 2026.7+
- `python3` in `$PATH` (used for safe JSON serialization during setup)
- Channel CLI tool installed: `imsg` (iMessage), `wacli` (WhatsApp), or `openclaw message` (Telegram/Discord/Slack)

## Supported Channels

| Channel | CLI | Address format |
|---------|-----|----------------|
| `imessage` | `imsg` | Email or phone (e.g. `user@icloud.com`, `+8615900000000`) |
| `whatsapp` | `wacli` | Phone with country code (e.g. `+1234567890`) |
| `telegram` | `openclaw message` | Chat ID or `@username` |
| `discord` | `openclaw message` | Channel ID (e.g. `1234567890`) |
| `slack` | `openclaw message` | Channel name or ID (e.g. `#general`) |

## Script Flags

| Flag | Effect |
|------|--------|
| `--force` | Skip the "overwrite existing hook?" prompt only |
| `--yes` | Skip the privacy confirmation prompt (for CI/automation) |

Note: `--force` does **not** skip the privacy confirmation. Use `--force --yes` together for fully non-interactive setup.

## Debugging Notifications

If notifications stop arriving, check the gateway log for `[gateway-restart-notify]` entries:

```bash
openclaw gateway logs | grep gateway-restart-notify
```

Notification failures are caught silently (to avoid blocking gateway startup) — the gateway log is the authoritative source for hook execution errors.

## Manual Setup

If you need to customize the hook, see [MANUAL.md](references/MANUAL.md) for step-by-step instructions.
