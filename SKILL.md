---
name: gateway-notify
description: "Set up automatic notifications when OpenClaw gateway restarts. Use when user wants to be notified of gateway startup events via any messaging channel (iMessage, WhatsApp, Telegram, Discord, etc.)."
---

# Gateway Notify

Automatically send notifications when the OpenClaw gateway starts up.

## What It Does

Creates a hook that triggers on `gateway:startup` events and sends a minimal notification (startup timestamp only) to the user's preferred channel.

> **Privacy notice:** This hook auto-runs on every gateway startup and sends a message to your chosen messaging channel. Only the startup timestamp is transmitted — no local configuration, model names, or network details leave your machine.

## Quick Start

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

The script will:
1. Create the hook directory at `~/.openclaw/hooks/gateway-restart-notify`
2. Generate the handler with the specified channel configuration (with security hardening)
3. Restart the gateway to activate (OpenClaw 2026.7+ auto-loads hooks, no explicit enable needed)

## How It Works

The hook uses OpenClaw's internal hook system:
- Listens for `gateway:startup` events
- Collects gateway startup time
- Sends notification via the configured channel CLI

## Supported Channels

See [CHANNELS.md](references/CHANNELS.md) for channel-specific CLI commands and address formats.

## Manual Setup

If you need to customize the hook, see [MANUAL.md](references/MANUAL.md) for step-by-step instructions.
