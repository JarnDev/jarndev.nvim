-- Neovim 0.12.2 bug: injection/scope processing passes nil or stale TSNodes.
-- Guard: nil node, or userdata node whose :range() method has been GC'd.
do
  local orig = vim.treesitter.get_range
  vim.treesitter.get_range = function(node, source, metadata)
    if node == nil then
      return { 0, 0, 0, 0, 0, 0 }
    end
    if type(node) ~= 'table' and type(node.range) ~= 'function' then
      return { 0, 0, 0, 0, 0, 0 }
    end
    local ok, result = pcall(orig, node, source, metadata)
    return ok and result or { 0, 0, 0, 0, 0, 0 }
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