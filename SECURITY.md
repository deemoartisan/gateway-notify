# Security & Privacy

## What This Skill Does

This skill creates a hook that:
1. Listens for `gateway:startup` events
2. Sends a notification message (startup timestamp only) to your configured channel

## Security Considerations

### Input Validation
- **Channel names**: whitelisted via `case` statement — accepted values: `imessage`, `whatsapp`, `telegram`, `discord`, `slack`. Any other value causes the script to exit with an error.
- **Address**: JSON-encoded via `python3 json.dumps` before being embedded in the handler; re-parsed with `json.loads` in Python before writing to TypeScript source — no raw shell string is ever embedded

> Note: no format validation is performed on the address value itself (email, phone, username). The channel's CLI will reject invalid addresses at runtime.

### Command Injection Protection
- `execFile` is used in the handler (not `exec`/`spawn('sh -c ...')`), so the message never passes through a shell interpreter
- `python3 json.dumps` encodes all user-supplied values; Python re-serializes via `json.loads` + `json.dumps` before writing to TypeScript

### File Permissions
- Hook directory created with `chmod 700` — only the owner can read or write

### Rollback on Failure
- `trap cleanup EXIT` ensures partial hook directories are removed if setup fails mid-way

## Privacy

This skill does NOT:
- Send your API keys or credentials
- Access your personal data or local configuration
- Read sensitive OpenClaw settings

This skill ONLY:
- Sends a startup timestamp when the gateway starts
- Uses the messaging address YOU provide during setup

> **Third-party notice:** Messages are delivered via the channel's CLI and pass through that channel's servers, which may log message metadata (send time, sender identity).

## Dependencies

- `python3` must be available in `$PATH` (used for safe JSON serialization during setup)
- The channel's CLI tool must be installed (`imsg`, `wacli`, or `openclaw message`)

## Review Before Installing

- `scripts/setup_gateway_notify.sh` — setup script
- `scripts/uninstall_gateway_notify.sh` — uninstall script
- `references/MANUAL.md` — manual setup instructions

## Questions?

Open an issue on GitHub: https://github.com/deemoartisan/gateway-notify
