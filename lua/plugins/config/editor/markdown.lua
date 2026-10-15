return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
  ft = { 'markdown' },
  keys = {
    { '<leader>uM', '<cmd>RenderMarkdown toggle<cr>', desc = 'UI: render [M]arkdown on/off' },
  },
  opts = {
    heading = {
      sign = false,
      icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
    },
    code = {
      sign = false,
      width = 'block',
      right_pad = 1,
    },
    bullet = {
      icons = { '●', '○', '◆', '◇' },
    },
    checkbox = {
      unchecked = { icon = '󰄱 ' },
      checked = { icon = '󰱒 ' },
    },
  },
}
