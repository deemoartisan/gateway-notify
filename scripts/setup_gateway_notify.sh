#!/bin/bash
set -e

if [ $# -lt 2 ]; then
  echo "Usage: $0 <channel> <address>"
  echo "Examples:"
  echo "  $0 imessage user@example.com"
  echo "  $0 whatsapp +1234567890"
  echo "  $0 telegram @username"
  exit 1
fi

CHANNEL=$1
ADDRESS=$2
HOOK_DIR="$HOME/.openclaw/hooks/gateway-restart-notify"

# Input validation
if [[ ! "$CHANNEL" =~ ^[a-z]+$ ]]; then
  echo "Error: Invalid channel name. Only lowercase letters allowed."
  exit 1
fi

# Validate address format based on channel
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
esac

echo "Setting up gateway-restart-notify hook..."
echo "Channel: $CHANNEL"
echo "Address: $ADDRESS"

mkdir -p "$HOOK_DIR"

# Create HOOK.md
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

# Escape address for safe embedding (cross-platform)
SAFE_ADDRESS=$(printf '%s' "$ADDRESS" | awk '{gsub(/'\''/, "'\''\\'\'''\''"); print}')

# Create handler with validated inputs
cat > "$HOOK_DIR/handler.ts" << HANDLEREOF
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
    
    const message = \`🚀 Gateway started!

⏰ Time: \${timeStr}
🌐 Port: 127.0.0.1:18789\`;


    // Use validated channel and address
    const channel = '$CHANNEL';
    const address = '$SAFE_ADDRESS';
    
    let cmd;
    if (channel === 'imessage') {
      cmd = \`imsg send --to '\${address}' --text "\${message}"\`;
    } else if (channel === 'whatsapp') {
      cmd = \`wacli send --to '\${address}' --text "\${message}"\`;
    } else {
      cmd = \`openclaw message send --channel \${channel} --target '\${address}' --message "\${message}"\`;
    }
    
    await execAsync(cmd);
    console.log("[gateway-restart-notify] Notification sent");
  } catch (err) {
    console.error("[gateway-restart-notify] Failed:", err);
  }
};

export default handler;
HANDLEREOF

echo "✓ Created handler.ts"

openclaw hooks enable gateway-restart-notify
echo "✓ Hook enabled"

echo ""
echo "Setup complete! Restart gateway to test:"
echo "  openclaw gateway restart"
