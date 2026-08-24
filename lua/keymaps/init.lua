local map = vim.keymap.set

-- Clear highlights on search when pressing <Esc> in normal mode
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
map('n', ']d', function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'Next diagnostic' })
map('n', '[d', function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'Previous diagnostic' })

-- Exit terminal mode
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Disable arrow keys in normal mode
map('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
map('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
map('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
map('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Window navigation
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })

-- KKP (Kitty Keyboard Protocol) fires both press and release events for every special key.
-- Neovim processes the release as a second keystroke, doubling it.
-- Runs in kitty directly (KITTY_WINDOW_ID) or inside herdr (HERDR_ENV), which forwards
-- the host terminal's KKP into its panes without exporting kitty's env vars.
if vim.env.KITTY_WINDOW_ID or vim.env.HERDR_ENV then
  local _kkp_last = {}
  vim.on_key(function(key)
    if #key == 0 then
      return
    end
    local b = key:byte(1)
    if b >= 0x20 and b <= 0x7e then
      return
    end -- printable ASCII, ignore
    local now = vim.uv.hrtime()
    local last = _kkp_last[key] or 0
    if last > 0 and now - last < 200000000 then
      _kkp_last[key] = 0
      return ''
    end
    _kkp_last[key] = now
  end)

  -- :KKPDebug — log every key event for 10 s, then notify the path
  vim.api.nvim_create_user_command('KKPDebug', function()
    local log = assert(io.open('/tmp/kkp_debug.log', 'w'))
    local ns = vim.api.nvim_create_namespace 'kkp_debug_tmp'
    vim.on_key(function(key)
      local t = {}
      for i = 1, #key do
        t[i] = ('%02x'):format(key:byte(i))
      end
      log:write(os.clock() .. '  ' .. table.concat(t, ' ') .. '\n')
      log:flush()
    end, ns)
    vim.defer_fn(function()
      vim.on_key(nil, ns)
      log:close()
      vim.notify 'KKP log: /tmp/kkp_debug.log'
    end, 10000)
    vim.notify 'KKP debug active 10 s — press Enter, Tab, arrows, etc.'
  end, {})
end

map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })

-- Vim special keys reference drawer
map('n', '<leader>?', function()
  Snacks.win {
    file = vim.fn.stdpath 'config' .. '/doc/vim-keys.md',
    width = 0.6,
    height = 0.85,
    border = 'rounded',
    title = ' Vim Keys Reference ',
    title_pos = 'center',
    wo = { wrap = false, conceallevel = 2 },
    keys = { q = 'close', ['<Esc>'] = 'close' },
  }
end, { desc = 'Vim keys reference' })

map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Play video under cursor (or entered path) with mpv in its own window
map('n', '<leader>rv', function()
  local function play(path)
    local file = vim.fn.fnamemodify(vim.fn.expand(path), ':p')
    if not vim.uv.fs_stat(file) then
      vim.notify('File not found: ' .. file, vim.log.levels.ERROR)
      return
    end
    vim.fn.jobstart({ 'mpv', file }, { detach = true })
    vim.notify('Playing: ' .. vim.fn.fnamemodify(file, ':t'))
  end

  local file = vim.fn.fnamemodify(vim.fn.expand '<cfile>', ':p')
  if vim.uv.fs_stat(file) then
    play(file)
  else
    vim.ui.input({ prompt = 'Video file: ', completion = 'file' }, function(input)
      if input and input ~= '' then
        play(input)
      end
    end)
  end
end, { desc = 'Play video (mpv)' })
