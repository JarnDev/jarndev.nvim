# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A personal Neovim configuration originally forked from [Kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), now fully restructured into a modular layout. Plugin management is handled by **Lazy.nvim**.

## Code Style

Lua formatting is enforced by **Stylua** (`.stylua.toml`): 2-space indent, 160-column width, single quotes preferred. Run it with:

```sh
stylua .
```

## Architecture

### Entry Point

`init.lua` is minimal — it delegates to three modules:

```lua
require('bootstrap')  -- leader key, nerd font flag, lazy.nvim bootstrap
require('core')       -- options, autocommands
require('plugins')    -- lazy.setup() with all plugin imports
```

### Module Layout

```
lua/
  bootstrap/          Leader key, Nerd Font flag, lazy.nvim install
  core/               options.lua, autocommands.lua
  keymaps/            Global keymaps (window nav, KKP backspace fix, etc.)
  plugins/
    init.lua          lazy.setup() — imports all config categories
    config/
      ai/             codecompanion.nvim, claudecode.nvim
      completion/     blink.cmp
      database/       vim-dadbod, dadbod-ui, dadbod-completion
      editor/         which-key, autopairs, debug, lint, hover, oil, grug-far, kulala, markdown, sleuth
      formatting/     conform.nvim (stylua + prettierd)
      git/            gitsigns, diffview
      lsp/            nvim-lspconfig + mason stack
      terminal/       (empty — handled by snacks.nvim)
      testing/        neotest (python/go adapters)
      treesitter/     nvim-treesitter
      ui/             tokyonight, mini.nvim, neo-tree, noice, snacks, trouble, lualine, data_viewer, todo-comments
```

### Adding a New Plugin

Create a file in the appropriate `lua/plugins/config/<category>/` directory returning a valid Lazy spec table. Then add `{ import = 'plugins.config.<category>.<name>' }` to that category's `init.lua`.

### Key Architectural Notes

- **Completion**: blink.cmp (not nvim-cmp). LSP capabilities via `require('blink.cmp').get_lsp_capabilities()`.
- **Picker/Search**: snacks.nvim picker (not telescope). All `<leader>s*` keymaps and LSP `gd/gr/gI` route through `Snacks.picker.*`.
- **Dashboard**: snacks.nvim dashboard (not dashboard-nvim). Configured in `lua/plugins/config/ui/snacks.lua`.
- **Terminal/Lazygit**: snacks.nvim terminal/lazygit (`<leader>lg/ld/lt`), not toggleterm or kdheepak/lazygit.
- **Statusline**: lualine.nvim (mini.statusline is disabled in mini.lua).
- **AI**: claudecode.nvim (CLI terminal integration) + codecompanion.nvim (Anthropic API chat/inline). copilot.vim stays for ghost-text completions.
- **Hover**: hover.nvim (`K` = hover, `gK` = select provider). Configured in `lua/plugins/config/editor/hover.lua`.
- **KKP backspace fix**: `lua/keymaps/init.lua` contains a `vim.on_key` dedup for the Kitty Keyboard Protocol double-backspace bug.

### Active Plugin Summary

| Category | Key Plugins |
|----------|-------------|
| AI | codecompanion.nvim (`<leader>aa/ai/ac/ap`), claudecode.nvim (`<leader>aT/af`) |
| Completion | blink.cmp (LSP + snippets + copilot + dadbod) |
| Database | vim-dadbod, dadbod-ui, dadbod-completion |
| Editor | which-key, nvim-autopairs, nvim-dap+ui+go, nvim-lint, hover.nvim, oil.nvim (`-`), grug-far (`<leader>S`), kulala (`<leader>rr`) |
| Formatting | conform.nvim (`<leader>f`): stylua + prettierd |
| Git | gitsigns (`<leader>h*`), diffview (`<leader>gd/gh/gH/gc`) |
| LSP | nvim-lspconfig + mason + fidget |
| Testing | neotest (`<leader>tt/tf/ts/to/td`) |
| UI | snacks.nvim (dashboard/picker/lazygit/terminal/indent/notifier/scroll), trouble (`<leader>xx/xd/xq`), lualine, noice, neo-tree, tokyonight |

## Useful In-Editor Commands

- `:Lazy` — plugin manager UI (update, install, profile)
- `:Mason` — LSP/tool installer
- `:ConformInfo` — formatter status
- `:checkhealth` — full diagnostic health check
