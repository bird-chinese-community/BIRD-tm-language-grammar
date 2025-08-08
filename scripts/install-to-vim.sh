#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_SYNTAX="$REPO_ROOT/grammars/bird2.syntax.vim"
SRC_FTDETECT="$REPO_ROOT/misc/vim/ftdetect/bird2.vim"

if [[ ! -f "$SRC_SYNTAX" ]]; then
  echo "Error: grammar source not found: $SRC_SYNTAX" >&2
  exit 1
fi

VIM_HOME="${VIM_HOME:-$HOME/.vim}"
mkdir -p "$VIM_HOME/syntax" "$VIM_HOME/ftdetect"

INSTALL_SYNTAX="$VIM_HOME/syntax/bird2.vim"
cp "$SRC_SYNTAX" "$INSTALL_SYNTAX"

if [[ ! -f "$SRC_FTDETECT" ]]; then
  echo "Error: ftdetect source not found: $SRC_FTDETECT" >&2
  exit 1
fi

INSTALL_FTDETECT="$VIM_HOME/ftdetect/bird2.vim"
cp "$SRC_FTDETECT" "$INSTALL_FTDETECT"

echo "[bird2] Installed Vim syntax to: $INSTALL_SYNTAX"
echo "[bird2] Filetype detection written to: $INSTALL_FTDETECT"
echo "[bird2] Verify in Vim with: :verbose set ft? (should be filetype=bird2)"
