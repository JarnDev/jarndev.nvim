return {
  'echasnovski/mini.nvim',
  config = function()
    -- Treesitter-backed textobjects. mini.ai resolves these through the builtin
    -- `vim.treesitter.query.get(lang, 'textobjects')`, so the queries come from
    -- nvim-treesitter-textobjects (see treesitter/textobjects.lua).
    -- Note `f` is the function DEFINITION here (mini.ai's default `f` -- a function
    -- call -- moves to `u`, matching the common convention).
    local ai = require 'mini.ai'
    ai.setup {
      n_lines = 500,
      custom_textobjects = {
        f = ai.gen_spec.treesitter { a = '@function.outer', i = '@function.inner' },
        c = ai.gen_spec.treesitter { a = '@class.outer', i = '@class.inner' },
        o = ai.gen_spec.treesitter {
          a = { '@conditional.outer', '@loop.outer' },
          i = { '@conditional.inner', '@loop.inner' },
        },
        a = ai.gen_spec.treesitter { a = '@parameter.outer', i = '@parameter.inner' },
        u = ai.gen_spec.function_call(), -- mini.ai's original `f`
      },
    }

    -- which-key only knows vim's builtin textobjects (w, s, p, ...), so after
    -- `vi`, `da`, `gsai`... the popup never listed mini.ai's ones. Describe them
    -- for operator-pending and visual mode, including the next/last variants.
    local objects = {
      { ' ', desc = 'whitespace' },
      { '"', desc = '" string' },
      { "'", desc = "' string" },
      { '`', desc = '` string' },
      { '(', desc = '() block' },
      { ')', desc = '() block with ws' },
      { '[', desc = '[] block' },
      { ']', desc = '[] block with ws' },
      { '{', desc = '{} block' },
      { '}', desc = '{} block with ws' },
      { '<', desc = '<> block' },
      { '>', desc = '<> block with ws' },
      { '?', desc = 'user prompt' },
      { 'a', desc = 'argument' },
      { 'b', desc = ')]} block' },
      { 'c', desc = 'class' },
      { 'f', desc = 'function' },
      { 'o', desc = 'conditional / loop' },
      { 'q', desc = 'quote `"\'' },
      { 't', desc = 'tag' },
      { 'u', desc = 'function call' },
    }
    local wk_spec = { mode = { 'o', 'x' } }
    for prefix, name in pairs { i = 'inside', a = 'around', il = 'last', ['in'] = 'next', al = 'last', an = 'next' } do
      table.insert(wk_spec, { prefix, group = name })
      for _, obj in ipairs(objects) do
        local desc = prefix:sub(1, 1) == 'i' and obj.desc:gsub(' with ws', '') or obj.desc
        table.insert(wk_spec, { prefix .. obj[1], desc = desc })
      end
    end
    local ok_wk, wk = pcall(require, 'which-key')
    if ok_wk then
      wk.add(wk_spec, { notify = false })
    end
    -- Prefix `gs` so plain `s` is free for flash.nvim (no timeoutlen wait)
    require('mini.surround').setup {
      mappings = {
        add = 'gsa',
        delete = 'gsd',
        find = 'gsf',
        find_left = 'gsF',
        highlight = 'gsh',
        replace = 'gsr',
        update_n_lines = 'gsn',
      },
    }

    -- mini.surround reads the surrounding id with getcharstr(), where which-key
    -- can't reach, so `gsaiw` then left you guessing. Show a which-key-like list of
    -- the ids while it waits (after a short delay, so dot-repeat and fast typing
    -- never flash it). It closes as soon as the action ends or a prompt (function
    -- name, tag, `?`) takes over.
    local surround_ids = {
      { '( [ { <', 'pair, with inner space' },
      { ') ] } >', 'pair, tight' },
      { '" \' `', 'that char on both sides' },
      { 'b', ')]} brackets (find: any)' },
      { 'q', 'quotes (find: any)' },
      { 'f', 'function call (asks the name)' },
      { 't', 'tag (asks the tag)' },
      { '?', 'ask left and right' },
      { 'other', 'that char on both sides' },
    }
    local hint = { win = nil, pending = false }
    local function hint_close()
      if hint.win and vim.api.nvim_win_is_valid(hint.win) then
        vim.api.nvim_win_close(hint.win, true)
      end
      hint.win = nil
    end
    local function hint_open()
      local lines = {}
      for _, item in ipairs(surround_ids) do
        table.insert(lines, string.format(' %-7s  %s ', item[1], item[2]))
      end
      local width = 0
      for _, l in ipairs(lines) do
        width = math.max(width, vim.fn.strdisplaywidth(l))
      end
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      hint.win = vim.api.nvim_open_win(buf, false, {
        relative = 'editor',
        row = vim.o.lines - #lines - 4,
        col = vim.o.columns - width - 4,
        width = width,
        height = #lines,
        style = 'minimal',
        border = 'rounded',
        title = ' surrounding ',
        title_pos = 'center',
        focusable = false,
        zindex = 250,
      })
      vim.wo[hint.win].winhighlight = 'NormalFloat:WhichKeyNormal,FloatBorder:WhichKeyBorder,FloatTitle:WhichKeyTitle'
      vim.cmd.redraw()
    end
    local function with_hint(fn)
      return function(...)
        hint.pending = true
        vim.defer_fn(function()
          if hint.pending then
            hint_open()
          end
        end, 300)
        local ok, res = pcall(fn, ...)
        hint.pending = false
        hint_close()
        if not ok then
          error(res, 0)
        end
        return res
      end
    end
    -- The gs* mappings resolve 'v:lua.MiniSurround.<task>' at call time, so
    -- wrapping the public functions is enough.
    for _, task in ipairs { 'add', 'delete', 'replace', 'find', 'highlight' } do
      MiniSurround[task] = with_hint(MiniSurround[task])
    end
    local user_input = MiniSurround.user_input
    MiniSurround.user_input = function(...)
      hint.pending = false
      hint_close()
      return user_input(...)
    end

    -- mini.statusline disabled: lualine.nvim is used instead
    -- mini.tabline disabled: bufferline.nvim is used instead

    -- Inline highlights for #rrggbb / #rgb and for TODO-style words. Chosen over
    -- nvim-colorizer / highlight-colors because mini.nvim is already loaded.
    local hipatterns = require 'mini.hipatterns'
    hipatterns.setup {
      highlighters = {
        hex_color = hipatterns.gen_highlighter.hex_color(),
      },
    }

    require('mini.move').setup {
      -- Visual mode only: <A-hjkl> moves the selection. Normal-mode <A-hjkl> belongs to
      -- smart-splits (resize), so the line_* maps are off -- `V` then <A-j>/<A-k> moves
      -- one line. (They were <M-D-hjkl>, Alt+Super, which macOS / GNOME swallow.)
      mappings = {
        left = '<M-h>',
        right = '<M-l>',
        down = '<M-j>',
        up = '<M-k>',
        line_left = '',
        line_right = '',
        line_down = '',
        line_up = '',
      },
      options = {
        reindent_linewise = true,
      },
    }
  end,
}
