#!/bin/bash
set -e

if [ $# -lt 2 ]; then
  echo "Usage: $0 <channel> <address>"
  echo "Examples:"
  echo "  $0 imessage 277498782@qq.com"
  echo "  $0 whatsapp +1234567890"
  echo "  $0 telegram @username"
  exit 1
fi

CHANNEL=$1
ADDRESS=$2
HOOK_DIR="$HOME/.openclaw/hooks/gateway-restart-notify"

echo "Setting up gateway-restart-notify hook..."
echo "Channel: $CHANNEL"
echo "Address: $ADDRESS"

# Create hook directory
mkdir -p "$HOOK_DIR"

# Create HOOK.md
cat > "$HOOK_DIR/HOOK.md" << 'EOF'
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
EOF

echo "✓ Created HOOK.md"

# Determine CLI command based on channel
case "$CHANNEL" in
  imessage)
    CLI_CMD="imsg send --to $ADDRESS --text"
    ;;
  whatsapp)
    CLI_CMD="wacli send --to $ADDRESS --text"
    ;;
  telegram|discord|slack)
    CLI_CMD="openclaw message send --channel $CHANNEL --target $ADDRESS --message"
    ;;
  *)
    echo "Error: Unsupported channel '$CHANNEL'"
    echo "Supported: imessage, whatsapp, telegram, discord, slack"
    exit 1
    ;;
esac

# Create handler.ts
cat > "$HOOK_DIR/handler.ts" << 'HANDLER_EOF'
import { exec } from "child_process";
import { promisify } from "util";
import { readFileSync } from "fs";
import { homedir } from "os";

const execAsync = promisify(exec);

const handler = async (event) => {
  if (event.type !== "gateway" || event.action !== "startup") {
    return;
  }

  console.log("[gateway-restart-notify] Gateway started, sending notification");

  try {
    const configPath = `${homedir()}/.openclaw/openclaw.json`;
    const config = JSON.parse(readFileSync(configPath, 'utf-8'));
    const model = config.agents?.defaults?.model || "unknown";
    
    const now = new Date();
    const timeStr = now.toLocaleString('en-US', { hour12: false });
    
    const message = `🚀 Gateway started!

⏰ Time: ${timeStr}
🤖 Model: ${model}
🌐 Port: 127.0.0.1:18789`;

    await execAsync(`CLI_COMMAND_PLACEHOLDER "${message}"`);
    console.log("[gateway-restart-notify] Notification sent");
  } catch (err) {
    console.error("[gateway-restart-notify] Failed:", err);
  }
};

export default handler;
HANDLER_EOF

# Replace placeholder with actual CLI command
sed -i '' "s|CLI_COMMAND_PLACEHOLDER|$CLI_CMD|g" "$HOOK_DIR/handler.ts"

echo "✓ Created handler.ts"

# Enable hook
openclaw hooks enable gateway-restart-notify
echo "✓ Hook enabled"

echo ""
echo "Setup complete! Restart gateway to test:"
echo "  openclaw gateway restart"
