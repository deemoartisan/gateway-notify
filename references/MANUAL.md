# Manual Setup Guide

## Step 1: Create Hook Directory

```bash
mkdir -p ~/.openclaw/hooks/gateway-restart-notify
```

## Step 2: Create HOOK.md

Create `~/.openclaw/hooks/gateway-restart-notify/HOOK.md`:

```markdown
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
```

## Step 3: Create Handler

> **Privacy notice:** The handler below transmits only the startup timestamp to your messaging channel. No local config, model names, or port details are included.

Create `~/.openclaw/hooks/gateway-restart-notify/handler.ts` with your channel-specific command.

Example for iMessage:

```typescript
import { execFile } from "child_process";
import { promisify } from "util";
import { homedir } from "os";

const execFileAsync = promisify(execFile);

// Replace with your CLI command and address
const CLI_BIN = "imsg";
const CLI_ARGS = ["send", "--to", "YOUR_ADDRESS", "--text"];

const handler = async (event: any) => {
  // OpenClaw 2026.7+ no longer includes event.type/event.action
  // HOOK.md events filter ensures this only fires on gateway:startup
  // Privacy: only timestamp is transmitted; no local config or sensitive data.
  try {
    const now = new Date();
    let timeStr: string;
    try {
      timeStr = now.toLocaleString("en-US", { hour12: false });
    } catch {
      timeStr = new Date(now.getTime()).toISOString().replace("T", " ").slice(0, 19);
    }

    const message = `🚀 Gateway started! ${timeStr}`;

    await execFileAsync(CLI_BIN, [...CLI_ARGS, message], { timeout: 10000 });
    console.log("[gateway-restart-notify] Notification sent");
  } catch (err) {
    console.error("[gateway-restart-notify] Failed:", err);
  }
};

export default handler;
```

Replace `YOUR_ADDRESS` and adjust `CLI_BIN` / `CLI_ARGS` for your channel.

## Step 4: Restart Gateway

```bash
openclaw gateway restart
```

The hook is automatically loaded from `~/.openclaw/hooks/` — no explicit enable command needed in OpenClaw 2026.7+.
