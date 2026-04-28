local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Mouse support
opt.mouse = 'a'

-- UI
opt.showmode = false
opt.signcolumn = 'yes'
opt.cursorline = true
opt.scrolloff = 10
opt.conceallevel = 2  -- needed for render-markdown.nvim

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

-- Whitespace display
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Smooth scrolling (Neovim 0.10+)
opt.smoothscroll = true

-- Treesitter-based folding (folds open by default)
opt.foldmethod = 'expr'
opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.fillchars = { fold = ' ', foldopen = '▾', foldclose = '▸', foldsep = ' ' }
