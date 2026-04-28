return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt = disable_filetypes[vim.bo[bufnr].filetype] and 'never' or 'fallback'
        return { timeout_ms = 500, lsp_format = lsp_format_opt }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'ruff_format', 'ruff_organize_imports' },
        javascript = { 'prettierd' },
        typescript = { 'prettierd' },
        javascriptreact = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        json = { 'prettierd' },
        jsonc = { 'prettierd' },
        html = { 'prettierd' },
        css = { 'prettierd' },
        scss = { 'prettierd' },
        yaml = { 'prettierd' },
        markdown = { 'prettierd' },
        graphql = { 'prettierd' },
      },
    },
  },
}
