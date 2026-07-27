# 手动设置指南

## 步骤 1：创建钩子目录

```bash
mkdir -p ~/.openclaw/hooks/gateway-restart-notify
```

## 步骤 2：创建 HOOK.md

创建 `~/.openclaw/hooks/gateway-restart-notify/HOOK.md`：

```markdown
---
name: gateway-restart-notify
description: "网关启动时发送通知"
metadata:
  openclaw:
    emoji: "🚀"
    events: ["gateway:startup"]
---

# Gateway Restart Notify

网关启动时向用户发送通知。
```

## 步骤 3：创建处理器

创建 `~/.openclaw/hooks/gateway-restart-notify/handler.ts`，使用你的渠道专用命令。

iMessage 示例：

```typescript
import { execFile } from "child_process";
import { promisify } from "util";
import { readFile } from "fs/promises";
import { homedir } from "os";

const execFileAsync = promisify(execFile);

// 替换为你的 CLI 命令和地址
const CLI_BIN = "imsg";
const CLI_ARGS = ["send", "--to", "你的地址", "--text"];

const handler = async (event: any) => {
  // OpenClaw 2026.7+ 不再包含 event.type/event.action
  // HOOK.md 的 events 过滤已确保只在 gateway:startup 时触发
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
      timeStr = now.toLocaleString("zh-CN", { timeZone: "Asia/Shanghai", hour12: false });
    } catch {
      const offset = new Date(now.getTime() + 8 * 3600 * 1000);
      timeStr = offset.toISOString().replace("T", " ").slice(0, 19);
    }

    const message = `🚀 网关已启动！\n\n⏰ 时间：${timeStr}\n🤖 模型：${model}\n🌐 端口：${gatewayPort}`;

    await execFileAsync(CLI_BIN, [...CLI_ARGS, message], { timeout: 10000 });
    console.log("[gateway-restart-notify] 通知已发送");
  } catch (err) {
    console.error("[gateway-restart-notify] 失败:", err);
  }
};

export default handler;
```

将 `你的地址` 以及 `CLI_BIN` / `CLI_ARGS` 替换为你的渠道配置。

## 步骤 4：重启网关

```bash
openclaw gateway restart
```

OpenClaw 2026.7+ 会自动从 `~/.openclaw/hooks/` 加载钩子，无需额外的启用命令。
