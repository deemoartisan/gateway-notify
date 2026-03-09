# Supported Channels

## iMessage

**CLI**: `imsg`
**Address format**: Email or phone number (e.g., `user@icloud.com`, `277498782@qq.com`)
**Command**:
```bash
imsg send --to <address> --text "<message>"
```

## WhatsApp

**CLI**: `wacli`
**Address format**: Phone number with country code (e.g., `+1234567890`)
**Command**:
```bash
wacli send --to <address> --text "<message>"
```

## Telegram

**CLI**: `openclaw message`
**Address format**: Chat ID or username (e.g., `@username`, `123456789`)
**Command**:
```bash
openclaw message send --channel telegram --target <address> --message "<message>"
```

## Discord

**CLI**: `openclaw message`
**Address format**: Channel ID (e.g., `1234567890`)
**Command**:
```bash
openclaw message send --channel discord --target <address> --message "<message>"
```

## Slack

**CLI**: `openclaw message`
**Address format**: Channel name or ID (e.g., `#general`, `C1234567890`)
**Command**:
```bash
openclaw message send --channel slack --target <address> --message "<message>"
```
