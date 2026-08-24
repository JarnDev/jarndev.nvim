-- Neovim 0.12.2 bug: injection/scope processing passes nil or stale TSNodes.
-- Guard: nil node, or userdata node whose :range() method has been GC'd.
-- Stress-tested without this guard on 0.12.2 + nvim-treesitter main with no errors;
-- it now notifies the first time it actually triggers so it can be removed once confirmed unneeded.
do
  local orig = vim.treesitter.get_range
  local warned = false
  local function guarded()
    if not warned then
      warned = true
      vim.schedule(function()
        vim.notify('vim.treesitter.get_range guard triggered (see lua/core/autocommands.lua)', vim.log.levels.WARN)
      end)
    end
    return { 0, 0, 0, 0, 0, 0 }
  end
  vim.treesitter.get_range = function(node, source, metadata)
    if node == nil or (type(node) ~= 'table' and type(node.range) ~= 'function') then
      return guarded()
    end
    local ok, result = pcall(orig, node, source, metadata)
    if ok then
      return result
    end
    return guarded()
  end
end

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
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

-- conceallevel only where it matters (render-markdown); keeps JSON quotes etc. visible elsewhere
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('MarkdownConceal', { clear = true }),
  pattern = { 'markdown' },
  callback = function()
    vim.opt_local.conceallevel = 2
  end,
})
