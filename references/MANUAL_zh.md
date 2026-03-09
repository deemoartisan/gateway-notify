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
import { exec } from "child_process";
import { promisify } from "util";

const execAsync = promisify(exec);

const handler = async (event) => {
  if (event.type !== "gateway" || event.action !== "startup") {
    return;
  }

  try {
    const now = new Date();
    const timeStr = now.toLocaleString('zh-CN', { timeZone: 'Asia/Shanghai', hour12: false });
    
    const message = `🚀 网关已启动！

⏰ 时间: ${timeStr}
🌐 端口: 127.0.0.1:18789`;

    await execAsync(`imsg send --to '你的地址' --text "${message}"`);
  } catch (err) {
    console.error("[gateway-restart-notify] 失败:", err);
  }
};

export default handler;
```

将 `你的地址` 和命令替换为你的渠道 CLI。

## 步骤 4：启用钩子

```bash
openclaw hooks enable gateway-restart-notify
```

## 步骤 5：重启网关

```bash
openclaw gateway restart
```
