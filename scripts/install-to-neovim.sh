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

if [[ -f "$SRC_PLUGIN_LUA" ]]; then
  cp "$SRC_PLUGIN_LUA" "$NVIM_CONFIG_DIR/plugin/bird2-filetype.lua"
else
  cat > "$NVIM_CONFIG_DIR/plugin/bird2-filetype.lua" <<'EOF'
-- Auto-register BIRD2 filetype (Neovim Lua)
local api = vim.api

-- Heuristic detector scanning first N lines for BIRD2-specific markers
local function bird2_looks_like(bufnr)
  bufnr = bufnr or 0
  local total = api.nvim_buf_line_count(bufnr)
  local max = math.min(total, 200)
  local protocols = { 'bgp','ospf','rip','device','direct','kernel','pipe','babel','radv','rpki','bfd' }
  for i = 0, max - 1 do
    local line = (api.nvim_buf_get_lines(bufnr, i, i + 1, false)[1] or ''):lower()
    if line:match('^%s*router%s+id')
      or line:match('^%s*template%s+')
      or line:match('^%s*filter%s+')
      or line:match('%f[%w]flow[46]%f[^%w]')
      or line:match('%f[%w]roa[46]?%f[^%w]')
      or line:match('%f[%w]aspa%f[^%w]')
    then
      return true
    end
    for _, p in ipairs(protocols) do
      if line:match('^%s*protocol%s+' .. p .. '%f[^%w]') then
        return true
      end
    end
  end
  return false
end

if vim.filetype and vim.filetype.add then
  vim.filetype.add({
    extension = {
      bird = 'bird2',
      bird2 = 'bird2',
      bird3 = 'bird2',
    },
    filename = {
      ['bird.conf'] = 'bird2',
      ['bird6.conf'] = 'bird2',
    },
    pattern = {
      ['.*/bird.*%.conf$'] = 'bird2',
      ['.*%.bird.*%.conf$'] = 'bird2',
      ['.*%.conf$'] = function(path, bufnr)
        if bird2_looks_like(bufnr) then
          return 'bird2'
        end
      end,
    },
  })
end

-- Fallback/override: if runtime sets ft=conf, adjust to bird2 when it matches
api.nvim_create_autocmd({ 'BufRead', 'BufNewFile', 'FileType' }, {
  pattern = '*.conf',
  callback = function(args)
    local bufnr = args.buf
    if vim.bo[bufnr].filetype == 'bird2' then return end
    if vim.bo[bufnr].filetype ~= '' and vim.bo[bufnr].filetype ~= 'conf' then return end
    if bird2_looks_like(bufnr) then
      vim.bo[bufnr].filetype = 'bird2'
    end
  end,
})
EOF
fi

echo "[bird2] Installed Neovim syntax to: $INSTALL_SYNTAX"
echo "[bird2] Lua filetype registration written to: $NVIM_CONFIG_DIR/plugin/bird2-filetype.lua"
echo "[bird2] Verify in Neovim with: :verbose set ft? (should be filetype=bird2)"
