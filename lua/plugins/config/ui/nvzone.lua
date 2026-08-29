-- NvChad's standalone UI widgets. `volt` is the shared rendering library both need.
return {
  { 'nvzone/volt', lazy = true },
  {
    'nvzone/minty',
    cmd = { 'Shades', 'Huefy' },
    keys = {
      { '<leader>uc', '<cmd>Huefy<cr>', desc = 'UI: [C]olor picker (Huefy)' },
      { '<leader>uC', '<cmd>Shades<cr>', desc = 'UI: color shades' },
    },
  },
  {
    'nvzone/menu',
    lazy = true,
    keys = {
      {
        '<RightMouse>',
        function()
          vim.cmd.exec '"normal! \\<RightMouse>"'
          local ft = vim.bo[vim.api.nvim_win_get_buf(vim.fn.getmousepos().winid)].filetype
          require('menu').open(ft == 'neo-tree' and 'nvimtree' or 'default', { mouse = true })
        end,
        mode = { 'n', 'v' },
        desc = 'Context menu',
      },
    },
  },
}
