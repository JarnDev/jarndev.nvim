-- Neovim 0.12.2 bug: injection query processing passes nil nodes to get_range.
-- Guard against it so the constant error notifications stop.
do
  local orig = vim.treesitter.get_range
  vim.treesitter.get_range = function(node, source, metadata)
    if node == nil then
      return { 0, 0, 0, 0, 0, 0 }
    end
    return orig(node, source, metadata)
  end
end

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Fix SQL comment string
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('FixSQLCommentString', { clear = true }),
  callback = function(ev)
    vim.bo[ev.buf].commentstring = '-- %s'
  end,
  pattern = { 'sql' },
}) 