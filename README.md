# Gateway Notify

Auto-notify when OpenAWS gateway restarts. Supports multiple messaging channels.

## Features

- 🚀 Automatic notification on gateway startup
- 📊 Shows model, time, and port info
- 🌐 Supports 5 channels: iMessage, WhatsApp, Telegram, Discord, Slack
- ⚡ One-command setup

## Quick Start

```bash
scripts/setup_gateway_notify.sh <channel> <address>
```

Examples:
```bash
scripts/setup_gateway_notify.sh imessage user@example.com
scripts/setup_gateway_notify.sh telegram @username
```

## Installation

```bash
openclaw skills install gateway-notify.skill
```

Or clone and use directly:
```bash
git clone https://github.com/YOUR_USERNAME/gateway-notify.git
cd gateway-notify
scripts/setup_gateway_notify.sh imessage your@email.com
```

## Documentation

- [English Manual](SKILL.md)
- [中文手册](../gateway-notify使用手册.md)

## License

MIT
