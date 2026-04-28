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
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Navigation via snacks.nvim picker
        map('gd', function() Snacks.picker.lsp_definitions() end, '[G]oto [D]efinition')
        map('gr', function() Snacks.picker.lsp_references() end, '[G]oto [R]eferences')
        map('gI', function() Snacks.picker.lsp_implementations() end, '[G]oto [I]mplementation')
        map('<leader>D', function() Snacks.picker.lsp_type_definitions() end, 'Type [D]efinition')
        map('<leader>ds', function() Snacks.picker.lsp_document_symbols() end, '[D]ocument [S]ymbols')
        map('<leader>ws', function() Snacks.picker.lsp_workspace_symbols() end, '[W]orkspace [S]ymbols')
        vim.keymap.set('n', '<leader>cn', function()
          return ':IncRename ' .. vim.fn.expand('<cword>')
        end, { buffer = event.buf, expr = true, desc = 'LSP: [R]e[n]ame' })
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- Highlight references
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    -- LSP capabilities
    local capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), require('blink.cmp').get_lsp_capabilities())

    -- LSP servers configuration
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
    }

    -- Mason setup
    require('mason').setup()
    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      'stylua',
      'markdownlint-cli2',
      'ruff',
      'prettierd',
      'eslint_d',
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    require('mason-lspconfig').setup {
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          require('lspconfig')[server_name].setup(server)
        end,
      },
    }
  end,
}