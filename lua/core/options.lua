-- Basic Neovim options
local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Mouse support
opt.mouse = 'a'

-- UI options
opt.showmode = false
opt.signcolumn = 'yes'
opt.cursorline = true
opt.scrolloff = 10

-- Clipboard
vim.schedule(function()
  opt.clipboard = 'unnamedplus'
end)

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = 'split'

-- Indentation
opt.breakindent = true
opt.undofile = true

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300

-- Window splitting
opt.splitright = true
opt.splitbelow = true

-- Whitespace
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
