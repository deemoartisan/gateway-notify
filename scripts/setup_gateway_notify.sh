#!/bin/bash
set -e

if [ $# -lt 2 ]; then
  echo "Usage: $0 <channel> <address> [account_id]"
  echo "Examples:"
  echo "  $0 imessage user@example.com"
  echo "  $0 whatsapp +1234567890"
  echo "  $0 telegram @username"
  echo "  $0 openclaw-weixin your_chat_id@im.wechat your_account_id"
  exit 1
fi

CHANNEL=$1
ADDRESS=$2
ACCOUNT_ID=${3:-}
HOOK_DIR="$HOME/.openclaw/hooks/gateway-restart-notify"

if [[ ! "$CHANNEL" =~ ^[a-z][a-z-]*$ ]]; then
  echo "Error: Invalid channel name. Only lowercase letters and hyphens allowed."
  exit 1
fi

case "$CHANNEL" in
  imessage)
    if [[ ! "$ADDRESS" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]] && [[ ! "$ADDRESS" =~ ^[0-9]+@[a-z]+\.[a-z]+$ ]]; then
      echo "Error: Invalid email format for iMessage"
      exit 1
    fi
    ;;
  whatsapp)
    if [[ ! "$ADDRESS" =~ ^\+[0-9]{10,15}$ ]]; then
      echo "Error: Invalid phone format for WhatsApp (use +countrycode)"
      exit 1
    fi
    ;;
  telegram)
    if [[ ! "$ADDRESS" =~ ^@[a-zA-Z0-9_]{5,32}$ ]] && [[ ! "$ADDRESS" =~ ^[0-9]+$ ]]; then
      echo "Error: Invalid Telegram username or chat ID"
      exit 1
    fi
    ;;
  openclaw-weixin)
    if [[ ! "$ADDRESS" =~ @im\.wechat$ ]]; then
      echo "Error: Invalid Weixin chat id (expected ...@im.wechat)"
      exit 1
    fi
    if [[ -z "$ACCOUNT_ID" ]]; then
      echo "Error: openclaw-weixin requires account_id as the 3rd argument"
      exit 1
    fi
    ;;
  *)
    ;;
esac

echo "Setting up gateway-restart-notify hook..."
echo "Channel: $CHANNEL"
echo "Address: $ADDRESS"
if [[ -n "$ACCOUNT_ID" ]]; then
  echo "Account ID: $ACCOUNT_ID"
fi

mkdir -p "$HOOK_DIR"

cat > "$HOOK_DIR/HOOK.md" << 'HOOKEOF'
---
name: gateway-restart-notify
description: "Send notification when gateway starts"
metadata:
  openclaw:
    emoji: "🚀"
    events: ["gateway:startup"]
---

# Gateway Restart Notify

Sends notification to user when gateway starts up.
HOOKEOF

echo "✓ Created HOOK.md"

# Escape values for safe embedding (cross-platform)
SAFE_ADDRESS=$(printf '%s' "$ADDRESS" | awk '{gsub(/'\''/, "'\''\\'\'''\''"); print}')
SAFE_ACCOUNT_ID=$(printf '%s' "$ACCOUNT_ID" | awk '{gsub(/'\''/, "'\''\\'\'''\''"); print}')
SAFE_CHANNEL=$(printf '%s' "$CHANNEL" | awk '{gsub(/'\''/, "'\''\\'\'''\''"); print}')

cat > "$HOOK_DIR/handler.ts" << 'HANDLEREOF'
import { exec } from "child_process";
import { promisify } from "util";

const execAsync = promisify(exec);

const handler = async (event) => {
  if (event.type !== "gateway" || event.action !== "startup") {
    return;
  }

  console.log("[gateway-restart-notify] Gateway started, sending notification");

  try {
    const now = new Date();
    const timeStr = now.toLocaleString('en-US', { hour12: false });
    const message = `🚀 Gateway started!\n\n⏰ Time: ${timeStr}\n🌐 Port: 127.0.0.1:18789`;

    const channel = '__CHANNEL__';
    const address = '__ADDRESS__';
    const accountId = '__ACCOUNT_ID__';

    let cmd;
    if (channel === 'imessage') {
      cmd = `imsg send --to '${address}' --text "${message}"`;
    } else if (channel === 'whatsapp') {
      cmd = `wacli send --to '${address}' --text "${message}"`;
    } else if (channel === 'openclaw-weixin') {
      cmd = `openclaw message send --channel ${channel} --target '${address}' --account '${accountId}' --message "${message}"`;
    } else {
      cmd = `openclaw message send --channel ${channel} --target '${address}' --message "${message}"`;
    }

    await execAsync(cmd);
    console.log("[gateway-restart-notify] Notification sent");
  } catch (err) {
    console.error("[gateway-restart-notify] Failed:", err);
  }
};

export default handler;
HANDLEREOF

python3 - "$HOOK_DIR/handler.ts" "$SAFE_CHANNEL" "$SAFE_ADDRESS" "$SAFE_ACCOUNT_ID" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
channel = sys.argv[2]
address = sys.argv[3]
account_id = sys.argv[4]
text = path.read_text()
text = text.replace('__CHANNEL__', channel)
text = text.replace('__ADDRESS__', address)
text = text.replace('__ACCOUNT_ID__', account_id)
path.write_text(text)
PY

echo "✓ Created handler.ts"

openclaw hooks enable gateway-restart-notify
echo "✓ Hook enabled"

echo ""
echo "Setup complete! Restart gateway to test:"
echo "  openclaw gateway restart"
