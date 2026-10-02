#!/usr/bin/env bash
# Launch isolated Neovim instance for Strudel Algorave livecoding
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_FILE="${1:-$SCRIPT_DIR/01_starter_beats.str}"

# Use dedicated isolated directories to guarantee zero interference with normal Neovim
export XDG_DATA_HOME="${HOME}/.local/share/nvim-strudel-sandbox"
export XDG_STATE_HOME="${HOME}/.local/state/nvim-strudel-sandbox"
export XDG_CACHE_HOME="${HOME}/.cache/nvim-strudel-sandbox"

mkdir -p "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"

echo "🎵 Starting Strudel live-coding sandbox..."
echo "📄 Opening: $TARGET_FILE"
echo "💡 Commands inside Neovim:"
echo "   :StrudelLaunch  (or <space>ml) - Open browser & connect audio"
echo "   :StrudelToggle  (or <space>mp) - Play / pause"
echo "   :StrudelUpdate  (or <space>mu) - Send buffer changes"
echo "   :StrudelQuit    (or <space>mq) - Close Strudel session"
echo ""

nvim -u "$SCRIPT_DIR/sandbox/init.lua" "$TARGET_FILE"
