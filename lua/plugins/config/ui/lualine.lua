return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      theme = 'tokyonight',
      globalstatus = true,
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'branch', 'diff', 'diagnostics' },
      lualine_c = { { 'filename', path = 1 } },
      lualine_x = {
        {
          function()
            local reg = vim.fn.reg_recording()
            return reg ~= '' and '󰑊 @' .. reg or ''
          end,
          color = { fg = '#ff9e64' },
        },
        {
          function()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            local names = {}
            for _, c in ipairs(clients) do
              if c.name ~= 'copilot' then
                table.insert(names, c.name)
              end
            end
            return #names > 0 and '󰒍 ' .. table.concat(names, ', ') or ''
          end,
        },
        'encoding',
        'fileformat',
        'filetype',
      },
      lualine_y = { 'progress' },
      lualine_z = { 'location' },
    },
  },
}
