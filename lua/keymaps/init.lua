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
