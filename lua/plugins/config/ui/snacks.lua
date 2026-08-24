return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    image = {
      -- Only terminals with the kitty graphics protocol can render; skip detection elsewhere.
      enabled = vim.env.KITTY_WINDOW_ID ~= nil or vim.env.WEZTERM_PANE ~= nil or vim.env.GHOSTTY_RESOURCES_DIR ~= nil,
      doc = {
        inline = false,
      },
    },
    dashboard = {
      enabled = true,
      preset = {
        header = [[
 ▄▄▄██▀▀▀▄▄▄       ██▀███   ███▄    █ ▓█████▄ ▓█████ ██▒   █▓
   ▒██  ▒████▄    ▓██ ▒ ██▒ ██ ▀█   █ ▒██▀ ██▌▓█   ▀▓██░   █▒
   ░██  ▒██  ▀█▄  ▓██ ░▄█ ▒▓██  ▀█ ██▒░██   █▌▒███   ▓██  █▒░
▓██▄██▓ ░██▄▄▄▄██ ▒██▀▀█▄  ▓██▒  ▐▌██▒░▓█▄   ▌▒▓█  ▄  ▒██ █░░
 ▓███▒   ▓█   ▓██▒░██▓ ▒██▒▒██░   ▓██░░▒████▓ ░▒████▒  ▒▀█░
 ▒▓▒▒░   ▒▒   ▓▒█░░ ▒▓ ░▒▓░░ ▒░   ▒ ▒  ▒▒▓  ▒ ░░ ▒░ ░  ░ ▐░
 ▒ ░▒░    ▒   ▒▒ ░  ░▒ ░ ▒░░ ░░   ░ ▒░ ░ ▒  ▒  ░ ░  ░  ░ ░░
 ░ ░ ░    ░   ▒     ░░   ░    ░   ░ ░  ░ ░  ░    ░       ░░
 ░   ░        ░  ░   ░              ░    ░       ░  ░     ░]],
        keys = {
          { icon = ' ', key = 'f', desc = 'Find File', action = ':lua Snacks.picker.files()' },
          { icon = ' ', key = 'p', desc = 'Projects', action = ':lua Snacks.picker.projects()' },
          { icon = ' ', key = 'r', desc = 'Recent Files', action = ':lua Snacks.picker.recent()' },
          { icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })" },
          { icon = ' ', key = 'w', desc = 'Find Word', action = ':lua Snacks.picker.grep()' },
          { icon = '󰒲 ', key = 'l', desc = 'Lazy', action = ':Lazy' },
          { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
        },
      },
      -- Two panes: logo (chafa) on the left, ASCII header + lists on the right.
      -- Snacks stacks the panes vertically when the window is narrower than 2*width+pane_gap.
      width = 64,
      pane_gap = 2,
      sections = {
        {
          section = 'terminal',
          cmd = ('chafa %s --format symbols --symbols vhalf --colors full --size 22x18; sleep .1'):format(
            vim.fn.shellescape(vim.fn.stdpath 'config' .. '/assets/logo.png')
          ),
          height = 18,
          indent = 20, -- center the 22-col logo inside the 64-col pane
          padding = 1,
          enabled = function()
            return vim.fn.executable 'chafa' == 1
          end,
        },
        {
          pane = 2,
          { section = 'header' },
          { section = 'keys', gap = 1, padding = 1 },
          { section = 'recent_files', limit = 5, padding = 1 },
          { section = 'projects', limit = 8, padding = 1 },
          { section = 'startup' },
        },
      },
    },
    gitbrowse = { enabled = true },
    indent = { enabled = true },
    lazygit = { enabled = true },
    notifier = { enabled = true },
    picker = { enabled = true },
    scroll = {
      enabled = true,
      filter = function(buf)
        return vim.bo[buf].filetype ~= 'neo-tree'
      end,
    },
    terminal = { enabled = true },
    words = { enabled = true },
  },
  keys = {
    -- Search / picker
    {
      '<leader>sf',
      function()
        Snacks.picker.files()
      end,
      desc = '[S]earch [F]iles',
    },
    {
      '<leader>sg',
      function()
        Snacks.picker.grep()
      end,
      desc = '[S]earch by [G]rep',
    },
    {
      '<leader>sh',
      function()
        Snacks.picker.help()
      end,
      desc = '[S]earch [H]elp',
    },
    {
      '<leader>sk',
      function()
        Snacks.picker.keymaps()
      end,
      desc = '[S]earch [K]eymaps',
    },
    {
      '<leader>ss',
      function()
        Snacks.picker.pickers()
      end,
      desc = '[S]earch [S]elect Picker',
    },
    {
      '<leader>sw',
      function()
        Snacks.picker.grep_word()
      end,
      desc = '[S]earch current [W]ord',
      mode = { 'n', 'x' },
    },
    {
      '<leader>sd',
      function()
        Snacks.picker.diagnostics()
      end,
      desc = '[S]earch [D]iagnostics',
    },
    {
      '<leader>sr',
      function()
        Snacks.picker.resume()
      end,
      desc = '[S]earch [R]esume',
    },
    {
      '<leader>sp',
      function()
        Snacks.picker.projects()
      end,
      desc = '[S]earch [P]rojects',
    },
    {
      '<leader>s.',
      function()
        Snacks.picker.recent()
      end,
      desc = '[S]earch Recent Files',
    },
    {
      '<leader>sn',
      function()
        Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
      end,
      desc = '[S]earch [N]eovim config',
    },
    {
      '<leader>s/',
      function()
        Snacks.picker.grep { grep_open_files = true }
      end,
      desc = '[S]earch [/] in Open Files',
    },
    {
      '<leader>/',
      function()
        Snacks.picker.lines()
      end,
      desc = '[/] Fuzzy search in buffer',
    },
    {
      '<leader><leader>',
      function()
        Snacks.picker.buffers()
      end,
      desc = '[ ] Find open buffers',
    },
    -- Git
    {
      '<leader>gB',
      function()
        Snacks.gitbrowse()
      end,
      desc = '[G]it [B]rowse (open in browser)',
      mode = { 'n', 'v' },
    },
    -- Dashboard
    {
      '<leader>H',
      function()
        Snacks.dashboard.open()
      end,
      desc = '[H]ome dashboard',
    },
    -- Terminals
    {
      '<leader>lg',
      function()
        Snacks.lazygit()
      end,
      desc = '[L]azy[G]it',
    },
    {
      '<leader>ld',
      function()
        Snacks.terminal 'lazydocker'
      end,
      desc = '[L]azy[D]ocker',
    },
    {
      '<leader>lt',
      function()
        Snacks.terminal()
      end,
      desc = '[L]aunch [T]erminal',
    },
  },
}
