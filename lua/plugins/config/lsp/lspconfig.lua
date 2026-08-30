return {
  -- LSP Configuration
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', config = true },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    'saghen/blink.cmp',
    'folke/neoconf.nvim',
  },
  config = function()
    -- Must run before any vim.lsp.config() call below so project-local `.neoconf.json`
    -- settings are merged into each server's config.
    require('neoconf').setup {}
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

        -- Call hierarchy ("who calls this?" / "what does this call?") via trouble's
        -- lsp_incoming_calls / lsp_outgoing_calls modes -- snacks.picker has no source for these.
        map('<leader>ci', '<cmd>Trouble lsp_incoming_calls toggle<cr>', '[C]alls [I]ncoming')
        map('<leader>co', '<cmd>Trouble lsp_outgoing_calls toggle<cr>', '[C]alls [O]utgoing')

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

      -- Shell / config formats
      bashls = {},
      yamlls = {},
      taplo = {},
      dockerls = {},

      -- C / C++. clangd reads compile_commands.json when present (cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1);
      -- for standalone study files it falls back to --fallback-style and default flags.
      clangd = {
        cmd = {
          'clangd',
          '--background-index',
          '--clang-tidy',
          '--header-insertion=iwyu',
          '--completion-style=detailed',
          -- clangd >= 20 requires an explicit boolean here; bare it is parsed as
          -- invalid and the flag is silently dropped.
          '--function-arg-placeholders=1',
          '--fallback-style=llvm',
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      },
      cmake = {},
    }

    for name, cfg in pairs(servers) do
      cfg.capabilities = vim.tbl_deep_extend('force', {}, capabilities, cfg.capabilities or {})
      vim.lsp.config(name, cfg)
    end

    -- Mason setup.
    --
    -- The two installers take DIFFERENT name spaces and must not be mixed:
    --   * mason-tool-installer takes mason *package* names ('lua-language-server').
    --   * mason-lspconfig takes *lspconfig* server names ('lua_ls') and maps them itself.
    -- Passing lspconfig names to mason-tool-installer makes it silently skip them, so the
    -- `servers` keys go to mason-lspconfig only and this list holds standalone tools.
    require('mason').setup()
    require('mason-tool-installer').setup {
      ensure_installed = {
        'stylua',
        'markdownlint-cli2',
        'prettierd',
        'eslint_d',
        'tree-sitter-cli',
        'shellcheck', -- bashls only emits diagnostics through shellcheck
        'clang-format',
        'cmakelang', -- provides cmake-format (conform: cmake filetype)
      },
    }

    -- mason-lspconfig v2 installs `ensure_installed` and enables every installed server
    -- via vim.lsp.enable(). Exclude tools that also ship an LSP mode but are used here as
    -- formatters/linters (stylua, ruff -> nvim-lint, eslint_d -> nvim-lint).
    require('mason-lspconfig').setup {
      ensure_installed = vim.tbl_keys(servers),
      automatic_enable = {
        exclude = { 'stylua', 'ruff', 'eslint_d' },
      },
    }
  end,
}
