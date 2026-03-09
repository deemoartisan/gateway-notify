# Changelog

All notable changes to this project will be documented in this file.

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
