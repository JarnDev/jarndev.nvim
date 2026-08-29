-- Extend <C-a>/<C-x> past plain integers. Without an explicit augend group this plugin
-- adds nothing over the builtin, so the group below is the whole point of installing it.
return {
  'monaqa/dial.nvim',
  keys = {
    {
      '<C-a>',
      function()
        return require('dial.map').inc_normal()
      end,
      expr = true,
      desc = 'Increment',
    },
    {
      '<C-x>',
      function()
        return require('dial.map').dec_normal()
      end,
      expr = true,
      desc = 'Decrement',
    },
    {
      '<C-a>',
      function()
        return require('dial.map').inc_visual()
      end,
      mode = 'v',
      expr = true,
      desc = 'Increment',
    },
    {
      '<C-x>',
      function()
        return require('dial.map').dec_visual()
      end,
      mode = 'v',
      expr = true,
      desc = 'Decrement',
    },
    {
      'g<C-a>',
      function()
        return require('dial.map').inc_gvisual()
      end,
      mode = 'v',
      expr = true,
      desc = 'Increment (ramp)',
    },
    {
      'g<C-x>',
      function()
        return require('dial.map').dec_gvisual()
      end,
      mode = 'v',
      expr = true,
      desc = 'Decrement (ramp)',
    },
  },
  config = function()
    local augend = require 'dial.augend'
    require('dial.config').augends:register_group {
      default = {
        augend.integer.alias.decimal_int, -- handles negatives
        augend.integer.alias.hex,
        augend.constant.alias.bool, -- true <-> false
        augend.constant.alias.alpha,
        augend.constant.alias.Alpha,
        augend.date.alias['%Y-%m-%d'],
        augend.date.alias['%Y/%m/%d'],
        augend.date.alias['%H:%M'],
        augend.semver.alias.semver,
        augend.constant.new { elements = { 'and', 'or' }, word = true, cyclic = true },
        augend.constant.new { elements = { 'True', 'False' }, word = true, cyclic = true },
        augend.constant.new { elements = { '&&', '||' }, word = false, cyclic = true },
      },
    }
  end,
}
