# 手动设置指南

> **前置要求：** OpenClaw 网关 2026.7+、`python3` 在 `$PATH` 中、已安装对应渠道的 CLI。

## 步骤 1：创建钩子目录

```bash
mkdir -p ~/.openclaw/hooks/gateway-restart-notify
chmod 700 ~/.openclaw/hooks/gateway-restart-notify
```

## 步骤 2：创建 HOOK.md

创建 `~/.openclaw/hooks/gateway-restart-notify/HOOK.md`：

```yaml
---
name: gateway-restart-notify
description: "网关启动时发送通知"
metadata:
  openclaw:
    emoji: "🚀"
    events:
      - gateway:startup
---
```

## 步骤 3：创建处理器

> **隐私提示：** 下面的默认处理器**只发送启动时间戳**。不读取本地配置、不发送模型名称、API 密钥或端口信息。
>
> **注意：** 通知失败会被静默捕获（避免阻塞网关启动）。如果通知不再送达，请在网关日志里查找 `[gateway-restart-notify]`。

创建 `~/.openclaw/hooks/gateway-restart-notify/handler.ts`：

```typescript
import { execFile } from "child_process";
import { promisify } from "util";

const execFileAsync = promisify(execFile);

// 替换为你的 CLI 命令和地址
const CLI_BIN  = "imsg";                                   // imsg | wacli | openclaw
const CLI_ARGS = ["send", "--to", "你的地址", "--text"];    // 消息文本前的参数

const handler = async (event: any) => {
  // HOOK.md 的 events 过滤已确保只在 gateway:startup 时触发。
  // 隐私：只发送时间戳，不读取任何本地配置或敏感数据。
  try {
    const now = new Date();
    let timeStr: string;
    try {
      timeStr = now.toLocaleString("zh-CN", { timeZone: "Asia/Shanghai", hour12: false });
    } catch {
      // 回退：输出 UTC 时间（任意时区可用）
      timeStr = now.toISOString().replace("T", " ").slice(0, 19) + " UTC";
    }

    const message = `🚀 网关已启动！\n\n⏰ ${timeStr}`;

    await execFileAsync(CLI_BIN, [...CLI_ARGS, message], { timeout: 10000 });
    console.log("[gateway-restart-notify] 通知已发送");
  } catch (err) {
    console.error("[gateway-restart-notify] 失败:", err);
    // 不要 re-throw：通知失败绝不能阻塞网关启动
  }
};

export default handler;
```

将 `你的地址` 以及 `CLI_BIN` / `CLI_ARGS` 替换为你的渠道配置。

### 各渠道的 CLI_BIN / CLI_ARGS

| 渠道 | CLI_BIN | CLI_ARGS |
|------|---------|---------|
| iMessage | `imsg` | `["send", "--to", "你的地址", "--text"]` |
| WhatsApp | `wacli` | `["send", "--to", "你的地址", "--text"]` |
| Telegram | `openclaw` | `["message", "send", "--channel", "telegram", "--target", "你的地址", "--message"]` |
| Discord | `openclaw` | `["message", "send", "--channel", "discord", "--target", "你的地址", "--message"]` |
| Slack | `openclaw` | `["message", "send", "--channel", "slack", "--target", "你的地址", "--message"]` |

## 步骤 4：重启网关

```bash
openclaw gateway restart
```

OpenClaw 2026.7+ 会自动从 `~/.openclaw/hooks/` 加载钩子，无需额外的启用命令。

## （可选）自定义消息内容 —— 请自担风险

> ⚠️ **数据外发警告：** 默认处理器只发送时间戳。如果你**主动选择**在消息中加入本地配置（例如模型名称、网关端口），这些信息将被发送到第三方消息渠道，并可能被该渠道的服务器记录。**只有在你完全理解并接受这一数据流向时才这样做。**

如果你确实需要在通知里加入本地配置信息，可以自行读取 `openclaw.json`。下面是一个示例（**默认不启用**，需要你手动添加）：

```typescript
// ⚠️ 可选：读取本地配置并外发 —— 会把模型名/端口发送到第三方渠道
import { readFile } from "fs/promises";
import { homedir } from "os";

const raw = await readFile(`${homedir()}/.openclaw/openclaw.json`, "utf-8").catch(() => "{}");
const config = JSON.parse(raw);
const model = config.agents?.defaults?.model?.primary ?? "unknown";
const gatewayPort = config.gateway?.port ?? 18789;
// 然后把 model / gatewayPort 拼进 message —— 但请注意这些信息会离开你的机器
```

## 卸载

> ⚠️ 下面的命令会永久删除钩子目录，执行前请先确认路径。

推荐使用卸载脚本，会弹出确认并提示是否重启网关：

```bash
scripts/uninstall_gateway_notify.sh
```

手动删除（仅限固定的钩子路径，执行前先确认）：

```bash
# 先确认目标路径，再删除
ls -la ~/.openclaw/hooks/gateway-restart-notify
rm -rf ~/.openclaw/hooks/gateway-restart-notify
openclaw gateway restart
```
