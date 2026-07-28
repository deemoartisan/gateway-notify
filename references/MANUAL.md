# Manual Setup Guide

> **Requirements:** OpenClaw gateway 2026.7+, `python3` in `$PATH`, channel CLI installed.

## Step 1: Create Hook Directory

```bash
mkdir -p ~/.openclaw/hooks/gateway-restart-notify
chmod 700 ~/.openclaw/hooks/gateway-restart-notify
```

## Step 2: Create HOOK.md

Create `~/.openclaw/hooks/gateway-restart-notify/HOOK.md`:

```yaml
---
name: gateway-restart-notify
description: "Send notification when gateway starts"
metadata:
  openclaw:
    emoji: "🚀"
    events:
      - gateway:startup
---
```

## Step 3: Create Handler

> **Privacy notice:** The handler below transmits only the startup timestamp to your messaging channel. No local config, model names, API keys, or port details are included.
>
> **Note:** Notification failures are caught silently to avoid blocking gateway startup. Check gateway logs for `[gateway-restart-notify]` if notifications stop arriving.

Create `~/.openclaw/hooks/gateway-restart-notify/handler.ts`:

```typescript
import { execFile } from "child_process";
import { promisify } from "util";

const execFileAsync = promisify(execFile);

// Replace with your CLI command and address
const CLI_BIN  = "imsg";                                   // imsg | wacli | openclaw
const CLI_ARGS = ["send", "--to", "YOUR_ADDRESS", "--text"]; // args before message text

const handler = async (event: any) => {
  // HOOK.md events filter ensures this only fires on gateway:startup.
  // Privacy: only timestamp is transmitted; no local config or sensitive data.
  try {
    const now = new Date();
    let timeStr: string;
    try {
      timeStr = now.toLocaleString("zh-CN", { timeZone: "Asia/Shanghai", hour12: false });
    } catch {
      // Fallback: UTC time (works in any timezone)
      timeStr = now.toISOString().replace("T", " ").slice(0, 19) + " UTC";
    }

    const message = `🚀 Gateway started!\n\n⏰ ${timeStr}`;

    await execFileAsync(CLI_BIN, [...CLI_ARGS, message], { timeout: 10000 });
    console.log("[gateway-restart-notify] Notification sent");
  } catch (err) {
    console.error("[gateway-restart-notify] Failed:", err);
    // Do NOT re-throw: notification failure must never block gateway startup
  }
};

export default handler;
```

### Channel-specific CLI_BIN / CLI_ARGS

| Channel | CLI_BIN | CLI_ARGS |
|---------|---------|---------|
| iMessage | `imsg` | `["send", "--to", "YOUR_ADDRESS", "--text"]` |
| WhatsApp | `wacli` | `["send", "--to", "YOUR_ADDRESS", "--text"]` |
| Telegram | `openclaw` | `["message", "send", "--channel", "telegram", "--target", "YOUR_ADDRESS", "--message"]` |
| Discord | `openclaw` | `["message", "send", "--channel", "discord", "--target", "YOUR_ADDRESS", "--message"]` |
| Slack | `openclaw` | `["message", "send", "--channel", "slack", "--target", "YOUR_ADDRESS", "--message"]` |

## Step 4: Restart Gateway

```bash
openclaw gateway restart
```

The hook is automatically loaded from `~/.openclaw/hooks/` — no explicit enable command needed in OpenClaw 2026.7+.

## Uninstall

> ⚠️ The command below permanently deletes the hook directory. Review the path before running it.

The recommended way is the uninstall script, which prompts for confirmation and offers to restart the gateway:

```bash
scripts/uninstall_gateway_notify.sh
```

Manual removal (only the fixed hook path; confirm before running):

```bash
# Confirm the target path first, then remove
ls -la ~/.openclaw/hooks/gateway-restart-notify
rm -rf ~/.openclaw/hooks/gateway-restart-notify
openclaw gateway restart
```
