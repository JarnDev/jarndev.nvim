return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    print '[dashboard-nvim] Starting configuration...'
    local status_ok, dashboard = pcall(require, 'dashboard')
    if not status_ok then
      print '[dashboard-nvim] Failed to load dashboard module'
      return
    end
    print '[dashboard-nvim] Setting up dashboard'
    dashboard.setup {
      theme = 'hyper',
      config = {
        header = {
          [[ ▄▄▄██▀▀▀▄▄▄       ██▀███   ███▄    █ ▓█████▄ ▓█████ ██▒   █▓]],
          [[   ▒██  ▒████▄    ▓██ ▒ ██▒ ██ ▀█   █ ▒██▀ ██▌▓█   ▀▓██░   █▒]],
          [[   ░██  ▒██  ▀█▄  ▓██ ░▄█ ▒▓██  ▀█ ██▒░██   █▌▒███   ▓██  █▒░]],
          [[▓██▄██▓ ░██▄▄▄▄██ ▒██▀▀█▄  ▓██▒  ▐▌██▒░▓█▄   ▌▒▓█  ▄  ▒██ █░░]],
          [[ ▓███▒   ▓█   ▓██▒░██▓ ▒██▒▒██░   ▓██░░▒████▓ ░▒████▒  ▒▀█░  ]],
          [[ ▒▓▒▒░   ▒▒   ▓▒█░░ ▒▓ ░▒▓░░ ▒░   ▒ ▒  ▒▒▓  ▒ ░░ ▒░ ░  ░ ▐░  ]],
          [[ ▒ ░▒░    ▒   ▒▒ ░  ░▒ ░ ▒░░ ░░   ░ ▒░ ░ ▒  ▒  ░ ░  ░  ░ ░░  ]],
          [[ ░ ░ ░    ░   ▒     ░░   ░    ░   ░ ░  ░ ░  ░    ░       ░░  ]],
          [[ ░   ░        ░  ░   ░              ░    ░       ░  ░     ░  ]],
          [[                                       ░                 ░   ]],
          [[                                                             ]],
          [[                                                             ]],
        },

        shortcut = {
          { icon = ' ', desc = 'Find file', group = '@file', action = 'Telescope find_files', key = 'f' },
          { icon = ' ', desc = 'Recent files', group = 'DiagnosticHint', action = 'Telescope oldfiles', key = 'r' },
          {
            icon = ' ',
            desc = 'Open config',
            group = 'Number',
            action = function()
              local builtin = require 'telescope.builtin'
              builtin.find_files { cwd = vim.fn.stdpath 'config' }
            end,
            key = 'c',
          },
          { icon = ' ', desc = 'Find word', group = 'DiagnosticWarn', action = 'Telescope live_grep', key = 'w' },
          { icon = '󰒲 ', desc = 'Lazy', group = 'DiagnosticInfo', action = 'Lazy', key = 'l' },
          {
            icon = ' ',
            desc = 'Quit',
            group = 'Number',
            action = function()
              vim.api.nvim_input '<cmd>qa<cr>'
            end,
            key = 'q',
          },
        },
      },
    }

    -- Proper way to disable indent-blankline (ibl.nvim) on dashboard
    local ok_ibl, ibl = pcall(require, 'ibl')
    if ok_ibl then
      ibl.setup { exclude = { filetypes = { 'dashboard' } } }
    end

    print '[dashboard-nvim] Configuration complete'
  end,
}
