#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/bird2-install-check.XXXXXX")"

cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

VIM_HOME="$TEMP_DIR/vim"
XDG_CONFIG_HOME="$TEMP_DIR/xdg"
LEGACY_NVIM_PLUGIN="$XDG_CONFIG_HOME/nvim/plugin/bird2-filetype.lua"
mkdir -p "$(dirname "$LEGACY_NVIM_PLUGIN")"
printf '%s\n' '-- legacy installer output' >"$LEGACY_NVIM_PLUGIN"

HOME="$TEMP_DIR/home" \
  VIM_HOME="$VIM_HOME" \
  VIMRC="$TEMP_DIR/vimrc" \
  XDG_CONFIG_HOME="$XDG_CONFIG_HOME" \
  bash "$REPO_ROOT/scripts/install.sh" >/dev/null

cmp "$REPO_ROOT/external/bird2.vim/syntax/bird2.vim" "$VIM_HOME/syntax/bird2.vim"
cmp "$REPO_ROOT/external/bird2.vim/ftdetect/bird2.vim" "$VIM_HOME/ftdetect/bird2.vim"
cmp "$REPO_ROOT/external/bird2.vim/ftplugin/bird2.vim" "$VIM_HOME/ftplugin/bird2.vim"
cmp "$REPO_ROOT/external/bird2.vim/doc/bird2.txt" "$VIM_HOME/doc/bird2.txt"

NVIM_HOME="$XDG_CONFIG_HOME/nvim"
cmp "$REPO_ROOT/external/bird2.nvim/syntax/bird2.vim" "$NVIM_HOME/syntax/bird2.vim"
cmp "$REPO_ROOT/external/bird2.nvim/plugin/bird2.lua" "$NVIM_HOME/plugin/bird2.lua"
cmp "$REPO_ROOT/external/bird2.nvim/ftplugin/bird2.lua" "$NVIM_HOME/ftplugin/bird2.lua"
cmp "$REPO_ROOT/external/bird2.nvim/doc/bird2.txt" "$NVIM_HOME/doc/bird2.txt"

for module in config health init; do
  cmp "$REPO_ROOT/external/bird2.nvim/lua/bird2/$module.lua" "$NVIM_HOME/lua/bird2/$module.lua"
done

if [[ -e "$LEGACY_NVIM_PLUGIN" || -L "$LEGACY_NVIM_PLUGIN" ]]; then
  echo "Legacy Neovim plugin was not removed: $LEGACY_NVIM_PLUGIN" >&2
  exit 1
fi

echo "Compatibility installer layout check passed."
