local map = vim.keymap.set

-- Clear highlights on search when pressing <Esc> in normal mode
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Disable arrow keys in normal mode
map('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
map('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
map('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
map('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Window navigation
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })

-- Kitty KKP fires both press and release events for every special key.
-- Neovim processes the release as a second keystroke, doubling it.
-- Fix: for any non-printable key (control chars, Neovim special sequences),
-- suppress a repeat within 200 ms — that is the KKP release event.
-- Printable ASCII (0x20 space … 0x7e ~) is excluded: those are never doubled.
local _kkp_last = {}
vim.on_key(function(key)
  if #key == 0 then return end
  local b = key:byte(1)
  if b >= 0x20 and b <= 0x7e then return end -- printable ASCII, ignore
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
  local ns = vim.api.nvim_create_namespace('kkp_debug_tmp')
  vim.on_key(function(key)
    local t = {}
    for i = 1, #key do t[i] = ('%02x'):format(key:byte(i)) end
    log:write(os.clock() .. '  ' .. table.concat(t, ' ') .. '\n')
    log:flush()
  end, ns)
  vim.defer_fn(function()
    vim.on_key(nil, ns)
    log:close()
    vim.notify('KKP log: /tmp/kkp_debug.log')
  end, 10000)
  vim.notify('KKP debug active 10 s — press Enter, Tab, arrows, etc.')
end, {})

map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })

-- Vim special keys reference drawer
map('n', '<leader>?', function()
  Snacks.win({
    file = vim.fn.stdpath('config') .. '/doc/vim-keys.md',
    width = 0.6,
    height = 0.85,
    border = 'rounded',
    title = ' Vim Keys Reference ',
    title_pos = 'center',
    wo = { wrap = false, conceallevel = 2 },
    keys = { q = 'close', ['<Esc>'] = 'close' },
  })
end, { desc = 'Vim keys reference' })

map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

