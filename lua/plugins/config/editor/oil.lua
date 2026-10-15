return {
  'stevearc/oil.nvim',
  lazy = false,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    view_options = { show_hidden = true },
  },
  keys = {
    { '-', '<cmd>Oil<cr>', desc = 'Open parent directory (oil)' },
  },
  init = function()
    -- Moving/renaming a file in oil tells the LSP (workspace/willRenameFiles), so e.g.
    -- tsserver rewrites the imports that pointed at it. oil hands over oil:// URLs;
    -- Snacks.rename wants plain paths.
    vim.api.nvim_create_autocmd('User', {
      pattern = 'OilActionsPost',
      callback = function(ev)
        for _, action in ipairs(ev.data.actions or {}) do
          if action.type == 'move' then
            Snacks.rename.on_rename_file(action.src_url:gsub('^oil://', ''), (action.dest_url:gsub('^oil://', '')))
          end
        end
      end,
    })
  end,
}
