return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'VeryLazy',
  opts = {
    options = {
      diagnostics = 'nvim_lsp',
      diagnostics_indicator = function(_, _, diag)
        local icons = { error = ' ', warning = ' ', hint = ' ' }
        local parts = {}
        for sev, icon in pairs(icons) do
          if diag[sev] and diag[sev] > 0 then
            parts[#parts + 1] = icon .. diag[sev]
          end
        end
        return #parts > 0 and table.concat(parts, ' ') or ''
      end,
      offsets = {
        {
          filetype = 'neo-tree',
          text = 'Explorer',
          highlight = 'Directory',
          text_align = 'left',
        },
      },
      close_command = function(n) Snacks.bufdelete(n) end,
      right_mouse_command = function(n) Snacks.bufdelete(n) end,
      show_buffer_close_icons = true,
      show_close_icon = false,
      separator_style = 'slant',
      always_show_bufferline = true,
    },
  },
  keys = {
    { '<leader><Tab>d', function() Snacks.bufdelete() end, desc = 'Close buffer' },
    { '<leader><Tab>u', '<cmd>e #<cr>', desc = 'Reopen last closed buffer' },
    { '<leader><Tab>U', function() Snacks.picker.recent() end, desc = 'Pick recent file to reopen' },
    { '<leader><Tab>p', '<cmd>BufferLinePick<cr>', desc = 'Pick buffer' },
    { '<leader><Tab>P', '<cmd>BufferLineTogglePin<cr>', desc = 'Pin/unpin buffer' },
  },
}
