local M = {}

-- Function to check if a plugin is installed
function M.has_plugin(plugin)
  return require('lazy.core.config').plugins[plugin] ~= nil
end

-- Function to create a new keymap
function M.map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Function to create a new autocommand
function M.create_autocmd(event, opts)
  vim.api.nvim_create_autocmd(event, opts)
end

-- Function to create a new augroup
function M.create_augroup(name, opts)
  return vim.api.nvim_create_augroup(name, opts)
end

return M
