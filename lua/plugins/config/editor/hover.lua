return {
  'lewis6991/hover.nvim',
  event = { 'LspAttach', 'VeryLazy' },
  config = function()
    -- hover.nvim's current API: config() with provider *module names*. The old
    -- setup{ init = ... } form is deprecated, and mouse_providers used to take
    -- display names ('LSP'), which no longer match anything.
    require('hover').config {
      providers = {
        'hover.providers.lsp',
        'hover.providers.dictionary',
        -- 'hover.providers.diagnostic', 'hover.providers.dap', 'hover.providers.man',
        -- 'hover.providers.gh', 'hover.providers.gh_user', 'hover.providers.jira',
        -- 'hover.providers.fold_preview', 'hover.providers.highlight',
      },
      preview_opts = {
        border = 'single',
      },
      -- Whether the contents of a currently open hover window should be moved
      -- to a :h preview-window when pressing the hover keymap.
      preview_window = false,
      title = true,
      mouse_providers = {
        'hover.providers.lsp',
      },
      mouse_delay = 1000,
    }

    -- K is reserved for LSP hover (set buffer-local in LspAttach below).
    -- gK opens the provider picker (dictionary, etc).
    -- select() indexes its opts without a nil check, so it must get a table.
    vim.keymap.set('n', 'gK', function()
      require('hover').select {}
    end, { desc = 'hover.nvim (select provider)' })

    -- Ensure K always means LSP hover in any buffer that has an LSP attached.
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('hover-lsp-k', { clear = true }),
      callback = function(ev)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = ev.buf, desc = 'LSP hover' })
      end,
    })

    -- Mouse support
    vim.keymap.set('n', '<MouseMove>', require('hover').mouse, { desc = 'hover.nvim (mouse)' })
    vim.o.mousemoveevent = true
  end,
}
