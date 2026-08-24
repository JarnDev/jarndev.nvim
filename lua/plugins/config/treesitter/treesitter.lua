-- nvim-treesitter `main` branch: no more `nvim-treesitter.configs`; the plugin only
-- installs parsers/queries. Highlighting, folding and indentation are driven by
-- Neovim's builtin treesitter APIs, enabled per-buffer below.
local ensure_installed = {
  'bash',
  'c',
  'diff',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'query',
  'vim',
  'vimdoc',
  'javascript',
  'typescript',
  'tsx',
  'go',
  'python',
  'yaml',
  'toml',
  'json',
  'regex',
}

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local ts = require 'nvim-treesitter'
    ts.setup {}

    -- Install missing parsers asynchronously (needs `tree-sitter` CLI >= 0.25, provided by Mason).
    local installed = ts.get_installed()
    local missing = vim.tbl_filter(function(lang)
      return not vim.tbl_contains(installed, lang)
    end, ensure_installed)
    if #missing > 0 then
      ts.install(missing)
    end

    -- Enable highlight + indent for any buffer whose filetype has a parser.
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
      callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match)
        if not lang then
          return
        end
        -- Auto-install parsers for new filetypes (replaces `auto_install = true`).
        if not vim.tbl_contains(ts.get_installed(), lang) and vim.tbl_contains(ts.get_available(), lang) then
          ts.install({ lang }):await(function()
            pcall(vim.treesitter.start, ev.buf, lang)
          end)
          return
        end
        if pcall(vim.treesitter.start, ev.buf, lang) then
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
