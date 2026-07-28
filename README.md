# Gateway Notify

Auto-notify when OpenClaw gateway restarts. Supports multiple messaging channels.

**Current version:** 2.1.5 — OpenClaw 2026.7+ compatible

## Features

- 🚀 Automatic notification on gateway startup
- ⏰ Shows startup timestamp (UTC fallback for any timezone)
- 🌐 Supports 5 channels: iMessage, WhatsApp, Telegram, Discord, Slack
- ⚡ One-command setup with `--force`/`--yes` flags for automation
- 🔒 Security: whitelist + JSON encoding + execFile, no shell interpreter
- ♻️ Rollback on failure, HOOK.md + handler.ts both verified after write
- 🗑️ Uninstall script with optional immediate gateway restart

## Privacy & Data Transmission

> ⚠️ **What gets sent, and where.** This skill installs a hook that runs on **every** gateway startup and sends a message to a third-party messaging service (iMessage, WhatsApp, Telegram, Discord, or Slack).

- **By default, only a startup timestamp is transmitted.** No model names, API keys, gateway port, or local configuration leaves your machine.
- Messages are delivered through the channel's own CLI and servers, which may log message metadata (send time, sender/recipient identifiers).
- The setup script requires explicit confirmation before installing (unless you pass `--yes` for automation).
- **Optional customization:** you may edit the handler to include local details (e.g. model, port). This is opt-in and off by default — see [MANUAL.md](references/MANUAL.md). Only do this if you accept that the added data will be sent externally.
- Permissions requested: `shell_exec`, `file_write`, `hook_install`, `network_send`, `gateway_restart`. The hook is persistent until you uninstall it.

## Requirements

- OpenClaw 2026.7.1-2 or later
- Python 3.6+ (for setup script)
- Channel-specific CLI tools (imsg, wacli, or openclaw message)

## Quick Start

```bash
scripts/setup_gateway_notify.sh <channel> <address>
```

Examples:
```bash
scripts/setup_gateway_notify.sh imessage user@example.com
scripts/setup_gateway_notify.sh telegram @username
scripts/setup_gateway_notify.sh discord 1234567890
```

## Installation

### Method 1: From GitHub

```bash
git clone https://github.com/deemoartisan/gateway-notify.git
cd gateway-notify
scripts/setup_gateway_notify.sh imessage your@email.com
openclaw gateway restart
```

### Method 2: From ClawHub

```bash
openclaw skills install gateway-notify
```

## Upgrade from v1.x

If you installed v1.0.x, the new version fixes critical compatibility issues with OpenClaw 2026.7+:

```bash
cd gateway-notify
git pull
scripts/setup_gateway_notify.sh <your-channel> <your-address>
openclaw gateway restart
```

## Documentation

- [SKILL.md](SKILL.md) — Quick reference
- [MANUAL.md](references/MANUAL.md) — Manual setup steps
- [CHANNELS.md](references/CHANNELS.md) — Channel-specific details
- [CHANGELOG.md](CHANGELOG.md) — Version history

## Supported Channels

| Channel | CLI Tool | Address Format |
|---------|----------|----------------|
| iMessage | `imsg` | Email or phone |
| WhatsApp | `wacli` | Phone with country code |
| Telegram | `openclaw message` | Username or Chat ID |
| Discord | `openclaw message` | Channel ID |
| Slack | `openclaw message` | Channel name or ID |

## What's New in v2.1.4

- 🔐 Complete permissions declaration (`hook_install`, `network_send`, `gateway_restart`)
- 🛡️ Privacy confirmation cannot be bypassed by `--force` (only `--yes` skips it)
- ♻️ Rollback on failure via `trap` registered before any file write
- ⏰ UTC timezone fallback (no longer hardcoded UTC+8)
- 🧹 Default handler sends **timestamp only** — no config data read or transmitted
- 🗑️ Uninstall script + confirmation-gated manual removal steps

## License

MIT-0

## Author

deemoartisan
