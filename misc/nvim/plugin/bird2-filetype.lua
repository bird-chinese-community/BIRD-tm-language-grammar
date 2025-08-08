-- Auto-register BIRD2 filetype (Neovim Lua)
local api = vim.api

-- Heuristic detector scanning first N lines for BIRD2-specific markers
local function bird2_looks_like(bufnr)
  bufnr = bufnr or 0
  local total = api.nvim_buf_line_count(bufnr)
  local max = math.min(total, 200)

  -- Enhanced protocol list including newer BIRD protocols
  local protocols = {
    'bgp', 'ospf', 'rip', 'device', 'direct', 'kernel', 'pipe',
    'babel', 'radv', 'rpki', 'bfd', 'static', 'l3vpn', 'mrt'
  }

  for i = 0, max - 1 do
    local line = (api.nvim_buf_get_lines(bufnr, i, i + 1, false)[1] or ''):lower()

    -- Skip empty lines and comments for better performance
    if line:match('^%s*$') or line:match('^%s*#') then
      goto continue
    end

    -- Core BIRD configuration patterns
    if line:match('^%s*router%s+id')
        or line:match('^%s*template%s+')
        or line:match('^%s*filter%s+')
        or line:match('^%s*function%s+')
        or line:match('^%s*table%s+')
        or line:match('^%s*define%s+')
        or line:match('%f[%w]flow[46]%f[^%w]')
        or line:match('%f[%w]roa[46]?%f[^%w]')
        or line:match('%f[%w]aspa%f[^%w]')
        or line:match('%f[%w]ipv[46]%s+table%f[^%w]')
    then
      return true
    end

    -- Protocol-specific detection
    for _, p in ipairs(protocols) do
      if line:match('^%s*protocol%s+' .. p .. '%f[^%w]') then
        return true
      end
    end

    ::continue::
  end

  return false
end

-- Register filetype detection using modern Neovim API
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
      -- Pattern matching for BIRD config files
      ['.*/bird.*%.conf$'] = 'bird2',
      ['.*%.bird.*%.conf$'] = 'bird2',
      -- Generic .conf files require content inspection
      ['.*%.conf$'] = function(path, bufnr)
        if bird2_looks_like(bufnr) then
          return 'bird2'
        end
      end,
    },
  })
end

-- Fallback mechanism: handle cases where filetype is initially set to 'conf'
-- but should be 'bird2' based on content
api.nvim_create_autocmd({ 'BufRead', 'BufNewFile', 'FileType' }, {
  pattern = '*.conf',
  callback = function(args)
    local bufnr = args.buf
    local current_ft = vim.bo[bufnr].filetype

    -- Skip if already correctly detected as bird2
    if current_ft == 'bird2' then
      return
    end

    -- Only override if filetype is empty or 'conf'
    if current_ft ~= '' and current_ft ~= 'conf' then
      return
    end

    -- Apply heuristic detection
    if bird2_looks_like(bufnr) then
      vim.bo[bufnr].filetype = 'bird2'
    end
  end,
})
