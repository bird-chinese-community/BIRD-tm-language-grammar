#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Minimal color for notice
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ $(tput colors 2>/dev/null || echo 0) -ge 8 ]]; then
  YELLOW="$(tput setaf 3)"; RESET="$(tput sgr0)"
else
  YELLOW=""; RESET=""
fi

echo -e "${YELLOW}[bird2] scripts/install-to-neovim.sh is deprecated. Use: bash scripts/install.sh --neovim${RESET}" >&2
exec "$REPO_ROOT/scripts/install.sh" --neovim
