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

-- Window navigation lives in plugins/config/editor/smart-splits.lua (<C-hjkl> to move,
-- <A-hjkl> to resize) so the same keys can cross into adjacent kitty panes.

-- LSP reference navigation. snacks.words is enabled in snacks.lua but binds no keys itself.
map({ 'n', 't' }, ']]', function()
  Snacks.words.jump(vim.v.count1)
end, { desc = 'Next reference' })
map({ 'n', 't' }, '[[', function()
  Snacks.words.jump(-vim.v.count1)
end, { desc = 'Previous reference' })

-- Config reference drawer: vim builtins + every installed plugin.
-- Opens folded by heading, so the ~16 top sections read like a table of contents:
-- <CR>/za opens one, zR/zM open/close all. `s` is a picker over every section heading
-- with a preview; <C-f> fuzzy-searches lines. Plain `/` still works (real buffer).
local function ref_fold(lnum)
  local hashes = vim.fn.getline(lnum):match '^(#+)%s'
  return hashes and ('>' .. #hashes) or '='
end
_G.jarndev_ref_fold = ref_fold

local function ref_sections(win)
  local items = {}
  for lnum, line in ipairs(vim.api.nvim_buf_get_lines(win.buf, 0, -1, false)) do
    local hashes, title = line:match '^(#+)%s+(.*)'
    if hashes and #hashes >= 2 then
      local indent = string.rep('  ', #hashes - 2)
      table.insert(items, { text = indent .. title, file = vim.api.nvim_buf_get_name(win.buf), pos = { lnum, 0 }, lnum = lnum })
    end
  end
  Snacks.picker.pick {
    title = 'Reference sections',
    items = items,
    format = 'text',
    preview = 'file',
    main = { current = true, float = true },
    confirm = function(picker, item)
      picker:close()
      if item and vim.api.nvim_win_is_valid(win.win) then
        vim.api.nvim_set_current_win(win.win)
        vim.api.nvim_win_set_cursor(win.win, { item.lnum, 0 })
        vim.cmd 'normal! zvzt' -- open the folds around it, heading at the top
      end
    end,
  }
end

map('n', '<leader>?', function()
  Snacks.win {
    file = vim.fn.stdpath 'config' .. '/doc/reference.md',
    width = 0.7,
    height = 0.85,
    border = 'rounded',
    title = ' Neovim Reference  (s sections · <CR> open · zR/zM all) ',
    title_pos = 'center',
    wo = {
      wrap = false,
      conceallevel = 2,
      foldmethod = 'expr',
      foldexpr = 'v:lua.jarndev_ref_fold(v:lnum)',
      foldtext = '', -- the heading line itself, highlighted
      foldlevel = 1, -- the H1 open, every ## section closed
      foldenable = true,
    },
    keys = {
      q = 'close',
      ['<Esc>'] = 'close',
      ['<CR>'] = function()
        vim.cmd 'normal! za'
      end,
      s = ref_sections,
      -- The picker's `main` window defaults to current=false/float=false, which
      -- would make it grep the buffer *behind* this float instead of the doc.
      ['<C-f>'] = function()
        Snacks.picker.lines { main = { current = true, float = true } }
      end,
    },
  }
end, { desc = 'Config reference (vim keys + plugins)' })

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

-- Undo history as a tree (Neovim 0.12's builtin nvim.undotree; undofile keeps it
-- across sessions, so an edit from yesterday is still one jump away)
vim.keymap.set('n', '<leader>uu', function()
  vim.cmd.packadd 'nvim.undotree'
  vim.cmd 'Undotree'
end, { desc = 'UI: [U]ndo tree' })

-- Plugin and tool managers
vim.keymap.set('n', '<leader>ul', '<cmd>Lazy<cr>', { desc = 'UI: [L]azy (plugins)' })
vim.keymap.set('n', '<leader>um', '<cmd>Mason<cr>', { desc = 'UI: [M]ason (LSP / tools)' })

-- Git worktrees (core/worktree.lua)
vim.keymap.set('n', '<leader>gw', function()
  require('core.worktree').pick()
end, { desc = 'Git: [W]orktrees (switch / <C-x> remove)' })
vim.keymap.set('n', '<leader>gW', function()
  require('core.worktree').create()
end, { desc = 'Git: new [W]orktree for a branch' })

-- GitHub Projects board (core/ghproject.lua)
vim.keymap.set('n', '<leader>gj', function()
  require('core.ghproject').pick()
end, { desc = 'Git: pro[J]ect board (GitHub Projects)' })
vim.keymap.set('n', '<leader>gJ', function()
  require('core.ghproject').pick { choose = true }
end, { desc = 'Git: pick another pro[J]ect' })
