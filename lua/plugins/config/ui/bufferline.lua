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
      show_buffer_close_icons = true,
      show_close_icon = false,
      separator_style = 'slant',
      always_show_bufferline = false,
    },
  },
  keys = {
    { '<leader><Tab>h', '<cmd>BufferLineCyclePrev<cr>', desc = 'Previous buffer' },
    { '<leader><Tab>l', '<cmd>BufferLineCycleNext<cr>', desc = 'Next buffer' },
    { '<leader><Tab>d', '<cmd>bdelete<cr>', desc = 'Delete buffer' },
    { '<leader><Tab>D', '<cmd>bdelete!<cr>', desc = 'Delete buffer (force)' },
    { '<leader><Tab>p', '<cmd>BufferLinePick<cr>', desc = 'Pick buffer' },
    { '<leader><Tab>P', '<cmd>BufferLineTogglePin<cr>', desc = 'Pin/unpin buffer' },
  },
}
