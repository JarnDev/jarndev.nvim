return {
  -- LSP Configuration
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', config = true },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    'saghen/blink.cmp',
  },
  config = function()
    -- LSP keymaps
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode, extra)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, vim.tbl_extend('force', { buffer = event.buf, desc = 'LSP: ' .. desc }, extra or {}))
        end

        -- Navigation via snacks.nvim picker
        map('gd', function()
          Snacks.picker.lsp_definitions()
        end, '[G]oto [D]efinition')
        -- nowait: avoid the timeout caused by Neovim's builtin gr* mappings (grn/grr/gra/gri)
        map('gr', function()
          Snacks.picker.lsp_references()
        end, '[G]oto [R]eferences', 'n', { nowait = true })
        map('gI', function()
          Snacks.picker.lsp_implementations()
        end, '[G]oto [I]mplementation')
        map('<leader>D', function()
          Snacks.picker.lsp_type_definitions()
        end, 'Type [D]efinition')
        map('<leader>ds', function()
          Snacks.picker.lsp_document_symbols()
        end, '[D]ocument [S]ymbols')
        map('<leader>ws', function()
          Snacks.picker.lsp_workspace_symbols()
        end, '[W]orkspace [S]ymbols')
        map('<leader>cn', function()
          return ':IncRename ' .. vim.fn.expand '<cword>'
        end, 'Re[n]ame', 'n', { expr = true })
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if not client then
          return
        end

        -- Highlight references
        if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        -- Inlay hints
        if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>ch', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, 'Toggle Inlay [H]ints')
        end
      end,
    })

    -- LSP capabilities (blink.cmp adds completion capabilities on top of the defaults)
    local capabilities = require('blink.cmp').get_lsp_capabilities()

    -- LSP servers configuration. Keys are lspconfig server names; values are passed to vim.lsp.config().
    local servers = {
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      },
      ts_ls = {},
      jsonls = {},
      html = {},
      cssls = {},
      tailwindcss = {},
      eslint = {},
      pyright = {},
      marksman = {},
    }

    for name, cfg in pairs(servers) do
      cfg.capabilities = vim.tbl_deep_extend('force', {}, capabilities, cfg.capabilities or {})
      vim.lsp.config(name, cfg)
    end

    -- Mason setup
    require('mason').setup()
    local ensure_installed = vim.tbl_keys(servers)
    vim.list_extend(ensure_installed, {
      'stylua',
      'markdownlint-cli2',
      'ruff',
      'prettierd',
      'eslint_d',
      'tree-sitter-cli',
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    -- mason-lspconfig v2 enables every installed server via vim.lsp.enable().
    -- Exclude tools that also ship an LSP mode but are used here as formatters/linters
    -- (stylua, ruff -> nvim-lint) and servers not in the `servers` table.
    require('mason-lspconfig').setup {
      ensure_installed = vim.tbl_keys(servers),
      automatic_enable = {
        exclude = { 'stylua', 'ruff', 'clangd', 'cmake', 'eslint_d' },
      },
    }
  end,
}
