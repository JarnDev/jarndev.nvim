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
          [[                                       ░                 ░  ]],
        },
        -- Default shortcuts for the 'hyper' theme
        shortcut = {
          { desc = '  Find file', group = '@file', action = 'Telescope find_files', key = 'f' },
          { desc = '  Recent files', group = 'DiagnosticHint', action = 'Telescope oldfiles', key = 'r' },
          { desc = '  Open config', group = 'Number', action = 'edit ~/.config/nvim/init.lua', key = 'c' },
          { desc = '  Find word', group = 'DiagnosticWarn', action = 'Telescope live_grep', key = 'w' },
          { desc = '  Lazy', group = 'DiagnosticInfo', action = 'Lazy', key = 'l' },
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
