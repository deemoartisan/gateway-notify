#!/bin/bash
set -euo pipefail

FORCE=false
YES=false

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    --yes)   YES=true ;;
  esac
done

HOOK_DIR="$HOME/.openclaw/hooks/gateway-restart-notify"

if [ ! -d "$HOOK_DIR" ]; then
  echo "Hook not found at $HOOK_DIR — nothing to uninstall."
  exit 0
fi

if [ "$YES" != true ]; then
  echo "⚠️  This will remove the gateway-restart-notify hook."
  echo "    Location: $HOOK_DIR"
  echo ""
  read -r -p "Proceed? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
fi

rm -rf "$HOOK_DIR"
echo "✓ Removed $HOOK_DIR"
echo ""
echo "⚠️  The hook is still active in the running gateway process until you restart."

if [ "$YES" != true ]; then
  read -r -p "Restart gateway now to deactivate? [y/N] " restart_confirm
  if [[ "$restart_confirm" =~ ^[Yy]$ ]]; then
    openclaw gateway restart
    echo "✓ Gateway restarted — hook is now deactivated."
  else
    echo "Remember to restart manually: openclaw gateway restart"
  fi
else
  echo "Run when ready: openclaw gateway restart"
fi
