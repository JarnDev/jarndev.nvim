-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load lazy.nvim
require("lazy").setup({
  -- Load plugin configurations
  spec = {
    -- Editor plugins
    { import = "plugins.config.editor" },
    -- Git plugins
    { import = "plugins.config.git" },
    -- UI plugins
    { import = "plugins.config.ui" },
    -- Terminal plugins
    { import = "plugins.config.terminal" },
    -- Testing plugins
    { import = "plugins.config.testing" },
    -- Database plugins
    { import = "plugins.config.database" },
    -- AI plugins
    { import = "plugins.config.ai" },
    -- LSP plugins
    { import = "plugins.config.lsp" },
    -- Completion plugins
    { import = "plugins.config.completion" },
    -- Treesitter plugins
    { import = "plugins.config.treesitter" },
    -- Formatting plugins
    { import = "plugins.config.formatting" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = {
    colorscheme = { "default" },
  },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
}) 