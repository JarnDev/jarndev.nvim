return {
  'folke/tokyonight.nvim',
  priority = 1000,
  opts = {
    style = 'night',
    -- JarnDev brand palette — mirrors portfolio globals.css @theme.
    -- Source of truth: JarnDev Brand System (board 07 — Terminal).
    on_colors = function(c)
      c.bg = '#07080b'
      c.bg_dark = '#05070a'
      c.fg = '#f4f6fb'
      c.cyan = '#22d3ee'
      c.blue = '#22d3ee'
      c.magenta = '#8b7cff'
      c.purple = '#8b7cff'
      c.green = '#7cff9b'
      c.yellow = '#fbbf24'
      c.comment = '#5b6472'
      c.border = '#232838'
    end,
  },
  config = function(_, opts)
    require('tokyonight').setup(opts)
    vim.cmd.colorscheme 'tokyonight-night'
    vim.cmd.hi 'Comment gui=none'
  end,
}
