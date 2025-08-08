#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_SYNTAX="$REPO_ROOT/grammars/bird2.syntax.vim"
SRC_PLUGIN_LUA="$REPO_ROOT/misc/nvim/plugin/bird2-filetype.lua"

if [[ ! -f "$SRC_SYNTAX" ]]; then
  echo "Error: grammar source not found: $SRC_SYNTAX" >&2
  exit 1
fi

NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
mkdir -p "$NVIM_CONFIG_DIR/syntax" "$NVIM_CONFIG_DIR/plugin"

INSTALL_SYNTAX="$NVIM_CONFIG_DIR/syntax/bird2.vim"
cp "$SRC_SYNTAX" "$INSTALL_SYNTAX"

if [[ ! -f "$SRC_PLUGIN_LUA" ]]; then
  echo "Error: plugin source not found: $SRC_PLUGIN_LUA" >&2
  exit 1
fi

INSTALL_PLUGIN="$NVIM_CONFIG_DIR/plugin/bird2-filetype.lua"
cp "$SRC_PLUGIN_LUA" "$INSTALL_PLUGIN"

echo "[bird2] Installed Neovim syntax to: $INSTALL_SYNTAX"
echo "[bird2] Lua filetype registration written to: $INSTALL_PLUGIN"
echo "[bird2] Verify in Neovim with: :verbose set ft? (should be filetype=bird2)"
