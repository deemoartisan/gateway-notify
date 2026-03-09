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
import { exec } from "child_process";
import { promisify } from "util";

const execAsync = promisify(exec);

const handler = async (event) => {
  if (event.type !== "gateway" || event.action !== "startup") {
    return;
  }

  try {
    const now = new Date();
    const timeStr = now.toLocaleString('en-US', { hour12: false });
    
    const message = `🚀 Gateway started!

⏰ Time: ${timeStr}
🌐 Port: 127.0.0.1:18789`;

    await execAsync(`imsg send --to 'YOUR_ADDRESS' --text "${message}"`);
  } catch (err) {
    console.error("[gateway-restart-notify] Failed:", err);
  }
};

export default handler;
```

Replace `YOUR_ADDRESS` and the command with your channel's CLI.

## Step 4: Enable Hook

```bash
openclaw hooks enable gateway-restart-notify
```

## Step 5: Restart Gateway

```bash
openclaw gateway restart
```
