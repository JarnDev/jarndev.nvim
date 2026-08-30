-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
  -- lazy.nvim is listed in lazy-lock.json, but `:Lazy restore` cannot restore the manager
  -- it is currently running from. A fresh clone therefore lands on whatever `stable` points
  -- at today, which leaves the committed lockfile dirty on a brand new install -- and the
  -- user's first `git pull` then fails under pull.rebase=true. Pin it here instead, before
  -- anything is loaded, so the lockfile means the same thing for the manager as for the 77
  -- plugins it manages.
  local lock = io.open(vim.fn.stdpath 'config' .. '/lazy-lock.json', 'r')
  if lock then
    local raw = lock:read '*a'
    lock:close()
    local ok, pinned = pcall(vim.json.decode, raw)
    local commit = ok and type(pinned) == 'table' and pinned['lazy.nvim'] and pinned['lazy.nvim'].commit
    if commit then
      vim.fn.system { 'git', '-C', lazypath, 'checkout', '--quiet', commit }
      if vim.v.shell_error ~= 0 then
        -- --branch=stable does not guarantee the locked commit is present locally.
        vim.fn.system { 'git', '-C', lazypath, 'fetch', '--quiet', 'origin', commit }
        vim.fn.system { 'git', '-C', lazypath, 'checkout', '--quiet', commit }
      end
    end
  end
end
vim.opt.rtp:prepend(lazypath)

-- Load lazy.nvim
require('lazy').setup {
  -- Load plugin configurations
  spec = {
    -- Editor plugins
    { import = 'plugins.config.editor' },
    -- Git plugins
    { import = 'plugins.config.git' },
    -- UI plugins
    { import = 'plugins.config.ui' },
    -- Terminal plugins
    { import = 'plugins.config.terminal' },
    -- Testing plugins
    { import = 'plugins.config.testing' },
    -- Database plugins
    { import = 'plugins.config.database' },
    -- AI plugins
    { import = 'plugins.config.ai' },
    -- LSP plugins
    { import = 'plugins.config.lsp' },
    -- Completion plugins
    { import = 'plugins.config.completion' },
    -- Treesitter plugins
    { import = 'plugins.config.treesitter' },
    -- Formatting plugins
    { import = 'plugins.config.formatting' },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = {
    colorscheme = { 'tokyonight-night' },
  },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
}
