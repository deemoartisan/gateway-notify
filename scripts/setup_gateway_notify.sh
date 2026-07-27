#!/bin/bash
set -eu

if [ $# -lt 2 ]; then
  echo "Usage: $0 <channel> <address>"
  echo "Examples:"
  echo "  $0 imessage yourname@qq.com"
  echo "  $0 whatsapp +1234567890"
  echo "  $0 telegram @username"
  echo "  $0 discord 1234567890"
  echo "  $0 slack '#general'"
  exit 1
fi

CHANNEL=$1
ADDRESS=$2
HOOK_DIR="$HOME/.openclaw/hooks/gateway-restart-notify"

# Check dependencies
if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: python3 is required but not found in PATH"
  echo "Install with: apt install python3  (Debian/Ubuntu) or brew install python3 (macOS)"
  exit 1
fi

# Warn if already installed
if [ -d "$HOOK_DIR" ]; then
  echo "⚠️  Hook already exists at $HOOK_DIR, overwriting..."
fi

echo "Setting up gateway-restart-notify hook..."
echo "Channel: $CHANNEL"
echo "Address: $ADDRESS"

mkdir -p "$HOOK_DIR"
chmod 700 "$HOOK_DIR"

# Create HOOK.md
cat > "$HOOK_DIR/HOOK.md" << 'EOF'
---
name: gateway-restart-notify
description: "Send notification when gateway starts"
metadata:
  openclaw:
    emoji: "🚀"
    events:
      - gateway:startup
---

# Gateway Restart Notify

Sends notification to user when gateway starts up.
EOF

echo "✓ Created HOOK.md"

# Build bin and args JSON separately — avoids split-on-space bugs and injection
# via ADDRESS containing quotes or special chars
case "$CHANNEL" in
  imessage)
    CLI_BIN="imsg"
    # python3 generates a safe JSON string literal for ADDRESS; bash just wraps the array brackets
    CLI_ARGS_JSON="[\"send\", \"--to\", $(printf '%s' "$ADDRESS" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'), \"--text\"]"
    ;;
  whatsapp)
    CLI_BIN="wacli"
    CLI_ARGS_JSON="[\"send\", \"--to\", $(printf '%s' "$ADDRESS" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'), \"--text\"]"
    ;;
  telegram|discord|slack)
    CLI_BIN="openclaw"
    CLI_ARGS_JSON="[\"message\", \"send\", \"--channel\", $(printf '%s' "$CHANNEL" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'), \"--target\", $(printf '%s' "$ADDRESS" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'), \"--message\"]"
    ;;
  *)
    echo "Error: Unsupported channel '$CHANNEL'"
    echo "Supported: imessage, whatsapp, telegram, discord, slack"
    exit 1
    ;;
esac

# Safely write handler.ts using python3 to avoid heredoc injection issues
python3 - "$HOOK_DIR/handler.ts" "$CLI_BIN" "$CLI_ARGS_JSON" << 'PYEOF'
import sys, json

out_path = sys.argv[1]
cli_bin = sys.argv[2]
cli_args_json = sys.argv[3]

handler = f"""import {{ execFile }} from "child_process";
import {{ promisify }} from "util";
import {{ readFile }} from "fs/promises";
import {{ homedir }} from "os";

const execFileAsync = promisify(execFile);

// CLI config injected by setup script
const CLI_BIN = {json.dumps(cli_bin)};
const CLI_ARGS = {cli_args_json}; // args before the message

const handler = async (event: any) => {{
  // event.type/event.action are not present in openclaw 2026.7+
  // HOOK.md events filter ensures this only fires on gateway:startup
  try {{
    const configPath = `${{homedir()}}/.openclaw/openclaw.json`;
    const raw = await readFile(configPath, "utf-8").catch(() => "{{}}");
    const config = JSON.parse(raw);

    const modelConfig = config.agents?.defaults?.model;
    const model =
      typeof modelConfig === "string"
        ? modelConfig
        : modelConfig?.primary ?? "unknown";

    const gatewayPort = config.gateway?.port ?? 18789;

    const now = new Date();
    // Fallback formatter in case ICU data is incomplete
    let timeStr: string;
    try {{
      timeStr = now.toLocaleString("zh-CN", {{ timeZone: "Asia/Shanghai", hour12: false }});
    }} catch {{
      const offset = new Date(now.getTime() + 8 * 3600 * 1000);
      timeStr = offset.toISOString().replace("T", " ").slice(0, 19);
    }}

    const message = `🚀 Gateway started!\\n\\n⏰ Time: ${{timeStr}}\\n🤖 Model: ${{model}}\\n🌐 Port: ${{gatewayPort}}`;

    await execFileAsync(CLI_BIN, [...CLI_ARGS, message], {{ timeout: 10000 }});
    console.log("[gateway-restart-notify] Notification sent");
  }} catch (err) {{
    console.error("[gateway-restart-notify] Failed:", err);
  }}
}};

export default handler;
"""

with open(out_path, "w") as f:
    f.write(handler)

print("✓ Created handler.ts")
PYEOF

echo ""
echo "Setup complete! Restart gateway to test:"
echo "  openclaw gateway restart"
echo ""
echo "Note: OpenClaw executes handler.ts directly via its built-in TS runtime (no compile step needed)."
