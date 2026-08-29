-- Pin a handful of files and jump between them by slot. Complements (does not replace)
-- `<leader><leader>` -- the buffer picker is a search, harpoon is muscle memory.
return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = function()
    local keys = {
      {
        '<leader>ja',
        function()
          require('harpoon'):list():add()
        end,
        desc = 'Harpoon: [A]dd file',
      },
      {
        '<leader>jj',
        function()
          local h = require 'harpoon'
          h.ui:toggle_quick_menu(h:list())
        end,
        desc = 'Harpoon: quick menu',
      },
      {
        '<leader>jn',
        function()
          require('harpoon'):list():next()
        end,
        desc = 'Harpoon: [N]ext file',
      },
      {
        '<leader>jp',
        function()
          require('harpoon'):list():prev()
        end,
        desc = 'Harpoon: [P]revious file',
      },
    }
    for i = 1, 4 do
      table.insert(keys, {
        '<leader>' .. i,
        function()
          require('harpoon'):list():select(i)
        end,
        desc = 'Harpoon: slot ' .. i,
      })
    end
    return keys
  end,
  config = function()
    require('harpoon'):setup()
  end,
}
