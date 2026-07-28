# Changelog

All notable changes to this project will be documented in this file.

## [2.1.4] - 2026-07-28

### Fixed
- `trap cleanup EXIT` now registered before `mkdir` — prevents orphaned hook directory if `chmod` fails
- Removed false address-format-validation claim from SECURITY.md (actual validation is done by the channel CLI at runtime)

### Added
- `--yes` flag for fully non-interactive setup (CI/automation); `--force` now only skips overwrite prompt
- `--force` and `--yes` can be passed in any argument order
- Privacy confirmation is now independent of `--force` — cannot be bypassed without explicit `--yes`
- `uninstall_gateway_notify.sh` with `--force`/`--yes` support and gateway restart prompt
- HOOK.md and handler.ts both verified with `[ ! -s ]` after write
- SKILL.md: Supported Channels table, Script Flags table, Debugging Notifications section
- MANUAL.md: updated handler template (UTC fallback, channel CLI table, uninstall section)
- SECURITY.md: explicit channel whitelist values, Dependencies section, third-party metadata notice

### Changed
- Timezone fallback in handler now emits UTC string instead of hardcoded UTC+8 offset
- Error message for unsupported channel uses `printf '%s'` (safe output)

## [2.0.0] - 2026-07-27

### Breaking Changes
- Requires OpenClaw 2026.7+ (event object structure changed)

### Fixed
- Remove `event.type/event.action` check — fields no longer present in OpenClaw 2026.7+
- `exec` → `execFile` to prevent shell injection via message content
- `readFileSync` → async `readFile` to avoid blocking the event loop
- CLI_CMD string split → `CLI_BIN` + `CLI_ARGS` array, handles spaces in addresses
- `ADDRESS` now escaped via `python3 json.dumps`, prevents code injection in generated TS
- Gateway port read from `openclaw.json`, no longer hardcoded to 18789
- Model read from `agents.defaults.model.primary` (new config structure)

### Added
- `python3` dependency check with install hint
- 10s timeout on notification command
- ICU locale fallback for environments with incomplete ICU data
- Overwrite warning when reinstalling
- HOOK.md `events` as YAML block sequence

### Reviewed
- Code reviewed by two independent agents before release

## [1.0.5] - 2026-03-09

### Fixed
- Cross-platform compatibility: replaced macOS-specific `sed` with `awk` for address escaping
- Script now works on Linux, macOS, and other Unix-like systems

## [1.0.3] - 2026-03-09

### Security
- Removed config file reading from MANUAL.md example code
- Removed personal account information from examples (privacy fix)

### Changed
- Updated SKILL.md examples to use generic placeholders
- Updated MANUAL.md handler example to not read openclaw.json

## [1.0.1] - 2026-03-09

### Security
- Added input validation for channel names and addresses
- Removed config file reading from handler (privacy improvement)
- Added proper escaping for shell command injection prevention
- Added SECURITY.md with detailed security and privacy information

### Changed
- Handler no longer reads `~/.openclaw/openclaw.json`
- Simplified notification message (removed model info)
- Improved error messages in setup script

## [1.0.0] - 2026-03-09

### Added
- Initial release
- Auto-notify on gateway startup
- Support for 5 messaging channels (iMessage, WhatsApp, Telegram, Discord, Slack)
- One-command setup script
- Complete English and Chinese documentation
- Gateway status display (model, time, port)

### Features
- Event-driven hook system using `gateway:startup`
- Automatic configuration and hook enablement
- Cross-platform channel support
- Detailed troubleshooting guide
