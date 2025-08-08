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

if [[ -f "$SRC_FTDETECT" ]]; then
  cp "$SRC_FTDETECT" "$VIM_HOME/ftdetect/bird2.vim"
else
  cat > "$VIM_HOME/ftdetect/bird2.vim" <<'EOF'
augroup bird2_ftdetect
  autocmd!
  " Filename-based detection
  autocmd BufRead,BufNewFile *.bird,*.bird2,*.bird3,*.bird*.conf setfiletype bird2
  autocmd BufRead,BufNewFile bird.conf,bird6.conf setfiletype bird2

  " Heuristic detection for generic *.conf (scan first 200 lines)
  function! s:Bird2MaybeSetFiletype() abort
    if &filetype !=# '' && &filetype !=# 'conf'
      return
    endif
    let l:max_lines = min([200, line('$')])
    let l:pat = '\v<(protocol\s+(bgp|ospf|rip|device|direct|kernel|pipe|babel|radv|rpki|bfd))|(^\s*router\s+id)|(^\s*template\s+)|(^\s*filter\s+)|(<flow[46]>)|(<roa[46]>)>'
    for lnum in range(1, l:max_lines)
      let l:line = getline(lnum)
      if l:line =~? l:pat
        setfiletype bird2
        return
      endif
    endfor
  endfunction
  autocmd BufRead,BufNewFile *.conf call s:Bird2MaybeSetFiletype()
augroup END
EOF
fi

echo "[bird2] Installed Vim syntax to: $INSTALL_SYNTAX"
echo "[bird2] Filetype detection written to: $VIM_HOME/ftdetect/bird2.vim"
echo "[bird2] Verify in Vim with: :verbose set ft? (should be filetype=bird2)"
