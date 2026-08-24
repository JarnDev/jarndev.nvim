local LOGO = vim.fn.stdpath 'config' .. '/assets/logo.png'
local LOGO_ROWS = 24 -- image height in terminal rows (800x576 px -> ~66 cols at 24 rows)
local LOGO_COLS = 66

-- Terminals that can speak the kitty graphics protocol (same check as `image.enabled` below).
-- Checked first so Snacks.image.supports_terminal() (a blocking terminal query) never runs
-- inside herdr/tmux/other terminals.
local function graphics_terminal()
  return vim.env.KITTY_WINDOW_ID ~= nil or vim.env.WEZTERM_PANE ~= nil or vim.env.GHOSTTY_RESOURCES_DIR ~= nil
end

local function logo_image_ok()
  return graphics_terminal() and vim.fn.filereadable(LOGO) == 1 and package.loaded['snacks'] ~= nil and Snacks.image.supports_terminal()
end

-- Place the real logo image over the blank header rows (kitty graphics protocol).
local function place_logo(buf)
  if not logo_image_ok() or vim.bo[buf].filetype ~= 'snacks_dashboard' then
    return
  end
  Snacks.image.placement.clean(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local first ---@type number? first non-blank row (1-indexed) = the keys section
  for i, l in ipairs(lines) do
    if l:find '%S' then
      first = i
      break
    end
  end
  if not first then
    return
  end
  local col = lines[first]:find '%S' - 1 -- left edge of the centered dashboard pane
  local row = first - 1 - LOGO_ROWS -- header rows precede the 1-line padding + keys
  if row < 1 then
    return
  end
  local left = col + math.floor((70 - LOGO_COLS) / 2)
  Snacks.image.placement.new(buf, LOGO, {
    inline = true,
    pos = { row, left },
    -- multi-line range + conceal => the image rows overlay the reserved blank lines
    -- (without it snacks would insert them as virtual lines and push the layout down)
    range = { row, left, row + LOGO_ROWS - 1, left },
    conceal = true,
    width = LOGO_COLS,
    height = LOGO_ROWS,
  })
end

vim.api.nvim_create_autocmd('User', {
  pattern = { 'SnacksDashboardOpened', 'SnacksDashboardUpdatePost' },
  group = vim.api.nvim_create_augroup('jarndev-dashboard-logo', { clear = true }),
  callback = function(ev)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(ev.buf) then
        place_logo(ev.buf)
      end
    end)
  end,
})

return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    image = {
      -- Only terminals with the kitty graphics protocol can render; skip detection elsewhere.
      enabled = graphics_terminal(),
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
      -- Header = the JarnDev logo (cat + wordmark). Three tiers, best available wins:
      --   1. Real image via the kitty graphics protocol (Snacks.image) when the terminal
      --      supports it (kitty/wezterm/ghostty directly; NOT inside herdr/tmux).
      --   2. chafa block-art in a terminal section.
      --   3. Plain ASCII header.
      width = 70,
      sections = {
        {
          -- Reserve LOGO_ROWS blank lines (raw header item, no section so the preset
          -- ASCII art is not used); the image is placed there on SnacksDashboardOpened.
          header = ('\n'):rep(LOGO_ROWS - 1),
          padding = 1,
          enabled = logo_image_ok,
        },
        {
          section = 'terminal',
          cmd = ('chafa %s --format symbols --symbols block+space --colors 2 --fg-only --dither none --work 9 --size 70x28; sleep .1'):format(
            vim.fn.shellescape(LOGO)
          ),
          height = 28,
          padding = 1,
          enabled = function()
            return not logo_image_ok() and vim.fn.executable 'chafa' == 1
          end,
        },
        {
          section = 'header',
          enabled = function()
            return not logo_image_ok() and vim.fn.executable 'chafa' ~= 1
          end,
        },
        { section = 'keys', gap = 1, padding = 1 },
        { section = 'recent_files', limit = 5, padding = 1 },
        { section = 'projects', limit = 8, padding = 1 },
        { section = 'startup' },
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
