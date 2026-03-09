# Gateway Notify - 网关重启通知

当 OpenAWS 网关启动时自动发送通知。

## 功能说明

创建一个钩子，在 `gateway:startup` 事件触发时，向用户首选的消息渠道发送网关状态通知。

## 快速开始

使用设置脚本配置消息渠道和地址：

```bash
scripts/setup_gateway_notify.sh <渠道> <地址>
```

示例：
```bash
scripts/setup_gateway_notify.sh imessage user@example.com
scripts/setup_gateway_notify.sh whatsapp +1234567890
scripts/setup_gateway_notify.sh telegram @username
```

脚本会自动：
1. 在 `~/.openclaw/hooks/gateway-restart-notify` 创建钩子目录
2. 生成配置好的处理器代码
3. 在 OpenAWS 配置中启用钩子
4. 重启网关以激活

## 工作原理

该钩子使用 OpenAWS 内部钩子系统：
- 监听 `gateway:startup` 事件
- 收集网关状态（时间、端口）
- 通过配置的渠道 CLI 发送通知

## 支持的渠道

查看 [CHANNELS.md](references/CHANNELS.md) 了解各渠道的 CLI 命令和地址格式。

## 手动设置

如需自定义钩子，请参阅 [MANUAL_zh.md](references/MANUAL_zh.md) 获取详细步骤。

## 安全与隐私

查看 [SECURITY.md](SECURITY.md) 了解安全措施和隐私保护。

## 许可证

MIT-0 - 免费使用、修改和再分发，无需署名。

## 链接

- GitHub: https://github.com/deemoartisan/gateway-notify
- ClawHub: https://clawhub.ai/deemoartisan/gateway-notify
