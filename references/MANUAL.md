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

Create `~/.openclaw/hooks/gateway-restart-notify/handler.ts` with your channel-specific command.

Example for iMessage:

```typescript
import { execFile } from "child_process";
import { promisify } from "util";
import { readFile } from "fs/promises";
import { homedir } from "os";

const execFileAsync = promisify(execFile);

// Replace with your CLI command and address
const CLI_BIN = "imsg";
const CLI_ARGS = ["send", "--to", "YOUR_ADDRESS", "--text"];

const handler = async (event: any) => {
  // OpenClaw 2026.7+ no longer includes event.type/event.action
  // HOOK.md events filter ensures this only fires on gateway:startup
  try {
    const configPath = `${homedir()}/.openclaw/openclaw.json`;
    const raw = await readFile(configPath, "utf-8").catch(() => "{}");
    const config = JSON.parse(raw);

    const modelConfig = config.agents?.defaults?.model;
    const model = typeof modelConfig === "string" ? modelConfig : modelConfig?.primary ?? "unknown";
    const gatewayPort = config.gateway?.port ?? 18789;

    const now = new Date();
    let timeStr: string;
    try {
      timeStr = now.toLocaleString("en-US", { hour12: false });
    } catch {
      const offset = new Date(now.getTime());
      timeStr = offset.toISOString().replace("T", " ").slice(0, 19);
    }

    const message = `🚀 Gateway started!\n\n⏰ Time: ${timeStr}\n🤖 Model: ${model}\n🌐 Port: ${gatewayPort}`;

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
