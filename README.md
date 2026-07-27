# Gateway Notify

Auto-notify when OpenClaw gateway restarts. Supports multiple messaging channels.

**Current version:** 2.0.0 — OpenClaw 2026.7+ compatible

## Features

- 🚀 Automatic notification on gateway startup
- 📊 Shows model, time, and port info
- 🌐 Supports 5 channels: iMessage, WhatsApp, Telegram, Discord, Slack
- ⚡ One-command setup
- 🔒 Security: shell injection prevention, async I/O, safe code generation

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

## What's New in v2.0

- ✅ Compatible with OpenClaw 2026.7+
- 🔒 Shell injection prevention via execFile
- ⚡ Non-blocking async file I/O
- 🛡️ Safe address escaping in generated code
- 🐍 Python3 dependency check
- 📊 Port auto-detection from config

## License

MIT-0

## Author

deemoartisan
