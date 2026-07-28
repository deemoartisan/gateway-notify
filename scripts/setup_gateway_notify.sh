#!/bin/bash
set -euo pipefail

# Parse arguments — order-independent flags
CHANNEL=""
ADDRESS=""
FORCE=false
YES=false

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    --yes)   YES=true ;;
    *)
      if [ -z "$CHANNEL" ]; then
        CHANNEL="$arg"
      elif [ -z "$ADDRESS" ]; then
        ADDRESS="$arg"
      fi
      ;;
  esac
done

if [ -z "$CHANNEL" ] || [ -z "$ADDRESS" ]; then
  echo "Usage: $0 <channel> <address> [--force] [--yes]"
  echo ""
  echo "  --force  Overwrite existing hook without prompting"
  echo "  --yes    Skip privacy confirmation (use in automated/CI environments)"
  echo ""
  echo "Examples:"
  echo "  $0 imessage yourname@qq.com"
  echo "  $0 whatsapp +1234567890"
  echo "  $0 telegram @username"
  echo "  $0 discord 1234567890"
  echo "  $0 slack '#general'"
  exit 1
fi

# Validate address not empty (catches explicit empty string "")
if [ -z "$ADDRESS" ]; then
  echo "Error: address cannot be empty" >&2
  exit 1
fi

# Check dependencies
if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: python3 is required but not found in PATH"
  echo "Install with: apt install python3  (Debian/Ubuntu) or brew install python3 (macOS)"
  exit 1
fi

HOOK_DIR="$HOME/.openclaw/hooks/gateway-restart-notify"

# --- Privacy confirmation (independent of --force) ---
echo "⚠️  Privacy & behavior notice:"
echo "    - This hook auto-runs on EVERY gateway startup"
echo "    - A notification is sent to your chosen channel on each startup"
echo "    - Only the startup timestamp is transmitted — no API keys, model names,"
echo "      or local paths leave your machine"
echo "    - Messages pass through the third-party channel's servers, which may"
echo "      log message metadata (send time, sender)"
echo "    - To uninstall later: scripts/uninstall_gateway_notify.sh"
echo "      (Deleting the skill alone does NOT stop the hook)"
echo ""
if [ "$YES" != true ]; then
  read -r -p "Accept and continue? [y/N] " privacy_confirm
  [[ "$privacy_confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
fi

# --- Overwrite confirmation (can be skipped with --force) ---
if [ -d "$HOOK_DIR" ]; then
  if [ "$FORCE" != true ]; then
    echo ""
    echo "⚠️  Hook already exists at $HOOK_DIR"
    read -r -p "Overwrite existing hook? [y/N] " overwrite_confirm
    [[ "$overwrite_confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
  else
    echo "⚠️  Hook already exists, overwriting (--force)..."
  fi
fi

echo ""
echo "Setting up gateway-restart-notify hook..."
echo "  Channel: $CHANNEL"
echo "  Address: $ADDRESS"

# --- Rollback on failure ---
# trap must be registered BEFORE mkdir so even a chmod failure is cleaned up
SETUP_DONE=false
cleanup() {
  if [ "$SETUP_DONE" = false ]; then
    echo "" >&2
    echo "Setup failed, rolling back..." >&2
    rm -rf "$HOOK_DIR"
    echo "Rolled back: removed $HOOK_DIR" >&2
  fi
}
trap cleanup EXIT

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

# Verify HOOK.md was written
if [ ! -s "$HOOK_DIR/HOOK.md" ]; then
  echo "Error: HOOK.md was not created or is empty" >&2
  exit 1
fi
echo "✓ Created HOOK.md"

# Build CLI_BIN and CLI_ARGS_JSON — channel is whitelisted, address is JSON-encoded
case "$CHANNEL" in
  imessage)
    CLI_BIN="imsg"
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
    echo "Error: Unsupported channel '$(printf '%s' "$CHANNEL")'" >&2
    echo "Supported: imessage, whatsapp, telegram, discord, slack" >&2
    exit 1
    ;;
esac

# Write handler.ts via python3.
# cli_args_json is re-parsed with json.loads() before embedding —
# never embed raw shell string into TypeScript source.
python3 - "$HOOK_DIR/handler.ts" "$CLI_BIN" "$CLI_ARGS_JSON" << 'PYEOF'
import sys, json

out_path = sys.argv[1]
cli_bin  = sys.argv[2]
cli_args_json = sys.argv[3]

# Re-parse and re-serialize: guarantees valid JSON regardless of shell quoting
cli_args = json.loads(cli_args_json)

handler = f"""import {{ execFile }} from "child_process";
import {{ promisify }} from "util";

const execFileAsync = promisify(execFile);

// CLI config injected by setup script
const CLI_BIN  = {json.dumps(cli_bin)};
const CLI_ARGS = {json.dumps(cli_args)}; // args before the message text

const handler = async (event: any) => {{
  // HOOK.md events filter ensures this only fires on gateway:startup.
  // Privacy: only the startup timestamp is transmitted.
  try {{
    const now = new Date();
    let timeStr: string;
    try {{
      timeStr = now.toLocaleString("zh-CN", {{ timeZone: "Asia/Shanghai", hour12: false }});
    }} catch {{
      // Fallback: emit UTC ISO string so users in any timezone get accurate time
      timeStr = now.toISOString().replace("T", " ").slice(0, 19) + " UTC";
    }}

    const message = `🚀 Gateway started!\\n\\n⏰ ${{timeStr}}`;

    await execFileAsync(CLI_BIN, [...CLI_ARGS, message], {{ timeout: 10000 }});
    console.log("[gateway-restart-notify] Notification sent");
  }} catch (err) {{
    console.error("[gateway-restart-notify] Failed:", err);
    // Do NOT re-throw: notification failure must never block gateway startup
  }}
}};

export default handler;
"""

with open(out_path, "w") as f:
    f.write(handler)

print("✓ Created handler.ts")
PYEOF

# Verify handler.ts was written
if [ ! -s "$HOOK_DIR/handler.ts" ]; then
  echo "Error: handler.ts was not created or is empty" >&2
  exit 1
fi
echo "✓ Verified handler.ts"

SETUP_DONE=true

echo ""
echo "✅ Setup complete!"
echo ""
echo "Restart gateway to activate the hook:"
echo "  openclaw gateway restart"
echo ""
echo "To uninstall later:"
echo "  scripts/uninstall_gateway_notify.sh"
