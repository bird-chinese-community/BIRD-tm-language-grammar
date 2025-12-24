#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SRC_SYNTAX="$REPO_ROOT/grammars/bird2.syntax.vim"
SRC_FTDETECT="$REPO_ROOT/misc/vim/ftdetect/bird2.vim"
SRC_PLUGIN_LUA="$REPO_ROOT/misc/nvim/plugin/bird2-filetype.lua"

# Color support
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ $(tput colors 2>/dev/null || echo 0) -ge 8 ]]; then
  BOLD="$(tput bold)"; RESET="$(tput sgr0)"
  BLUE="$(tput setaf 4)"; GREEN="$(tput setaf 2)"; YELLOW="$(tput setaf 3)"; RED="$(tput setaf 1)"
else
  BOLD=""; RESET=""; BLUE=""; GREEN=""; YELLOW=""; RED=""
fi

info() { echo -e "${BLUE}[bird2 syntax]${RESET} $*"; }
ok()   { echo -e "${GREEN}[bird2 syntax]${RESET} $*"; }
warn() { echo -e "${YELLOW}[bird2 syntax]${RESET} $*"; }
err()  { echo -e "${RED}[bird2 syntax]${RESET} $*" >&2; }

usage() {
  cat <<'EOF'
Usage: scripts/install.sh [--vim] [--neovim]
- With no flags, installs for both Vim and Neovim (if sources exist).
- Use --vim to install only Vim support.
- Use --neovim to install only Neovim support.

NOTE: Vim/Neovim support has moved to dedicated repositories:
  - Vim:   https://github.com/bird-chinese-community/bird2.vim
  - Neovim: https://github.com/bird-chinese-community/bird2.nvim

Consider using the dedicated plugins for better maintenance and features.
EOF
}

install_vim() {
  if [[ ! -f "$SRC_SYNTAX" ]]; then err "Grammar not found: $SRC_SYNTAX"; return 1; fi
  if [[ ! -f "$SRC_FTDETECT" ]]; then err "Vim ftdetect not found: $SRC_FTDETECT"; return 1; fi
  VIM_HOME="${VIM_HOME:-$HOME/.vim}"
  mkdir -p "$VIM_HOME/syntax" "$VIM_HOME/ftdetect"
  INSTALL_SYNTAX="$VIM_HOME/syntax/bird2.vim"
  INSTALL_FTDETECT="$VIM_HOME/ftdetect/bird2.vim"
  cp "$SRC_SYNTAX" "$INSTALL_SYNTAX"
  cp "$SRC_FTDETECT" "$INSTALL_FTDETECT"
  ok "Installed Vim syntax to: ${YELLOW}$INSTALL_SYNTAX${RESET}"
  ok "Filetype detection written to: ${YELLOW}$INSTALL_FTDETECT${RESET}"
}

install_neovim() {
  if [[ ! -f "$SRC_SYNTAX" ]]; then err "Grammar not found: $SRC_SYNTAX"; return 1; fi
  if [[ ! -f "$SRC_PLUGIN_LUA" ]]; then err "Neovim plugin not found: $SRC_PLUGIN_LUA"; return 1; fi
  NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
  mkdir -p "$NVIM_CONFIG_DIR/syntax" "$NVIM_CONFIG_DIR/plugin"
  INSTALL_SYNTAX="$NVIM_CONFIG_DIR/syntax/bird2.vim"
  INSTALL_PLUGIN="$NVIM_CONFIG_DIR/plugin/bird2-filetype.lua"
  cp "$SRC_SYNTAX" "$INSTALL_SYNTAX"
  cp "$SRC_PLUGIN_LUA" "$INSTALL_PLUGIN"
  ok "Installed Neovim syntax to: ${YELLOW}$INSTALL_SYNTAX${RESET}"
  ok "Lua filetype registration written to: ${YELLOW}$INSTALL_PLUGIN${RESET}"
}

# Ensure Vim enables filetype/plugins/indent and syntax highlighting
ensure_vim_runtime_config() {
  local vimrc="${VIMRC:-$HOME/.vimrc}"
  # Backup existing vimrc if present
  if [[ -f "$vimrc" ]]; then
    cp "$vimrc" "$vimrc.bak-$(date +%Y%m%d%H%M%S)"
  fi
  touch "$vimrc"
  if ! grep -qE '^[[:space:]]*filetype plugin indent on([[:space:]]|$)' "$vimrc"; then
    printf "\nfiletype plugin indent on\n" >> "$vimrc"
    ok "Enabled in ${YELLOW}$vimrc${RESET}: filetype plugin indent on"
  else
    info "${YELLOW}$vimrc${RESET} already enables: filetype plugin indent on"
  fi
  if ! grep -qE '^[[:space:]]*syntax on([[:space:]]|$)' "$vimrc"; then
    printf "syntax on\n" >> "$vimrc"
    ok "Enabled in ${YELLOW}$vimrc${RESET}: syntax on"
  else
    info "${YELLOW}$vimrc${RESET} already enables: syntax on"
  fi
}

# Ensure Neovim has syntax/filetype enabled via a small bootstrap plugin
ensure_neovim_runtime_config() {
  local nvim_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
  local bootstrap_lua="$nvim_config_dir/plugin/bird2-bootstrap.lua"
  mkdir -p "$nvim_config_dir/plugin"
  cat > "$bootstrap_lua" <<'LUA'
-- Auto-enable syntax and filetype for Neovim if not already enabled
if vim.g.syntax_on == nil then
  vim.cmd('syntax on')
end
-- Neovim generally enables filetype detection by default, but ensure plugin+indent too
if vim.g.did_load_filetypes == nil then
  vim.cmd('filetype plugin indent on')
end
LUA
  ok "Wrote Neovim bootstrap: ${YELLOW}$bootstrap_lua${RESET}"
}

DO_VIM=false; DO_NVIM=false
if [[ "$#" -gt 0 ]]; then
  for arg in "$@"; do
    case "$arg" in
      -h|--help) usage; exit 0 ;;
      --vim) DO_VIM=true ;;
      --neovim|--nvim) DO_NVIM=true ;;
      *) err "Unknown option: $arg"; usage; exit 2 ;;
    esac
  done
fi

if ! $DO_VIM && ! $DO_NVIM; then DO_VIM=true; DO_NVIM=true; fi

info "Installing BIRD2 syntax..."
$DO_VIM && { install_vim; ensure_vim_runtime_config; } || true
$DO_NVIM && { install_neovim; ensure_neovim_runtime_config; } || true

ok "Installation completed."

cat <<EOF

========================================
${BOLD}Next steps:${RESET}
- Open the sample config to verify highlighting:
  - Vim:    ${GREEN}vim "./sample/basic.conf"${RESET} + ${GREEN}:verbose set ft?${RESET}
  - Neovim: ${GREEN}nvim "./sample/basic.conf"${RESET} + ${GREEN}:verbose set ft?${RESET}
You should see: ${YELLOW}filetype=bird2${RESET}
========================================

${BLUE}${BOLD}NOTE:${RESET} Vim/Neovim support is now maintained in dedicated repositories:
  - Vim:   ${GREEN}https://github.com/bird-chinese-community/bird2.vim${RESET}
  - Neovim: ${GREEN}https://github.com/bird-chinese-community/bird2.nvim${RESET}

Consider using the dedicated plugins for automatic updates and better features!
EOF

