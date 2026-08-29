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
  keymaps/            Global keymaps (window nav, diagnostics, mpv, etc.)
  plugins/
    init.lua          lazy.setup() — imports all config categories
    config/
      ai/             codecompanion.nvim, claudecode.nvim
      completion/     blink.cmp
      database/       vim-dadbod, dadbod-ui, dadbod-completion
      editor/         which-key, autopairs, debug, lint, hover, oil, grug-far, kulala, markdown, sleuth,
                      harpoon, refactoring, ts-comments, overseer, neogen, dial, yanky, smart-splits
      formatting/     conform.nvim (stylua + prettierd)
      git/            gitsigns, diffview, octo
      lsp/            nvim-lspconfig + mason stack, neoconf
      terminal/       (empty — handled by snacks.nvim)
      testing/        neotest (python/jest adapters)
      treesitter/     nvim-treesitter, textobjects, context, autotag
      ui/             tokyonight, mini.nvim, neo-tree, noice, snacks, trouble, lualine, todo-comments,
                      bufferline, window-picker, smear-cursor, nvzone (volt/minty/menu), edgy, startuptime
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
- **Terminal**: kitty from the upstream installer (`os-custom-config/linux/install-kitty.sh`); the Ubuntu apt kitty 0.32.2 doubles Backspace/Enter under KKP (fixed in 0.33). No Neovim-side workaround is needed.
- **LSP servers**: configured with `vim.lsp.config()` in `lspconfig.lua`; mason-lspconfig v2 auto-enables installed servers (`automatic_enable.exclude` keeps stylua/ruff/eslint_d as tools only).
- **The two Mason installers take different name spaces** and must not be mixed: `mason-tool-installer` takes mason *package* names (`lua-language-server`), `mason-lspconfig` takes *lspconfig* server names (`lua_ls`) and maps them itself. Server names go in the `servers` table (-> mason-lspconfig); standalone tools go in the `mason-tool-installer` list. Passing an lspconfig name to mason-tool-installer makes it silently skip that package.
- **Textobjects**: `mini.ai` is backed by nvim-treesitter-textobjects queries, so `f` is the function *definition* (`vaf`/`vif`), `c` a class, `o` a conditional/loop, `a` a parameter, and `u` mini.ai's original function-*call* object. Motions `]f`/`[f` (function), `]C`/`[C` (class) and `]a`/`[a` (parameter) come from the same plugin — class uses capitals because `]c`/`[c` are gitsigns' hunk motions.
- **C/C++**: clangd (with clang-tidy) + clang-format via conform + codelldb for DAP (`Build & debug current file` compiles the buffer with `gcc`/`g++ -g -O0` next to the source).
- **Window navigation is smart-splits**, not raw `<C-w>` — `<C-hjkl>` moves, `<A-hjkl>` resizes. Crossing into adjacent *kitty* panes additionally needs kitty-side config (navigation kitten / `pass_keys`); without it the keys degrade to plain window nav. The old `<C-w>` maps were removed from `keymaps/init.lua`.
- **`p`/`P` are yanky**, giving a yank ring (`<C-p>`/`<C-n>` cycle right after a paste, `<leader>p` picks from history). yanky loads on `VeryLazy`, not on `p`, because the ring is built from `TextYankPost`.
- **`<C-a>`/`<C-x>` are dial**, with an explicit augend group (bools, dates, hex, semver, `and`/`or`, `&&`/`||`). Without that group the plugin would add nothing over the builtin.
- **neoconf must be set up before any `vim.lsp.config()` call** — it is a dependency of nvim-lspconfig and `require('neoconf').setup{}` is the first line of that spec's `config` function.
- **refactoring.nvim needs `lewis6991/async.nvim`** as a hard runtime dependency (`refactoring.lua:45`); omitting it fails at load with `module 'async' not found`.
- **Symbol outline is `<leader>xs`** (`Trouble symbols`) — aerial.nvim / outline.nvim are deliberately not installed. Trouble also provides `lsp_incoming_calls`, `lsp_outgoing_calls` and a `profiler` mode.
- **`]]`/`[[` are snacks.words** LSP-reference navigation, bound in `keymaps/init.lua` (snacks enables the module but binds no keys itself).

### Active Plugin Summary

| Category | Key Plugins |
|----------|-------------|
| AI | codecompanion.nvim (`<leader>aa/ai/ac/ap`), claudecode.nvim (`<leader>aT/af`) |
| Completion | blink.cmp (LSP + snippets + copilot + dadbod) |
| Database | vim-dadbod, dadbod-ui, dadbod-completion |
| Editor | which-key, nvim-autopairs, nvim-dap+ui (python/C/C++/JS), nvim-lint, hover.nvim, oil.nvim (`-`), grug-far (`<leader>S`), kulala (`<leader>rr`) |
| Navigation | harpoon2 (`<leader>j*`, `<leader>1-4`), smart-splits (`<C-hjkl>` / `<A-hjkl>`), window-picker (`<leader>wp`), flash (`s`/`S`) |
| Refactor/Docs | refactoring.nvim (`<leader>cr`), neogen (`<leader>cd`), inc-rename (`<leader>cn`), ts-comments (fixes `gc` in JSX) |
| Tasks | overseer.nvim (`<leader>o*`) |
| Editing | yanky (`p`/`P`, `<leader>p`), dial (`<C-a>`/`<C-x>`), mini.ai/surround/move |
| Formatting | conform.nvim (`<leader>f`): stylua + prettierd |
| Git | gitsigns (`<leader>h*`), diffview (`<leader>gd/gh/gH/gc`), octo (`<leader>gp/gi/gr/gO`, needs `gh auth login`) |
| LSP | nvim-lspconfig + mason + fidget + neoconf (`<leader>cN`) |
| Testing | neotest (`<leader>tt/tf/ts/to/td`) |
| UI | snacks.nvim (dashboard/picker/lazygit/terminal/indent/notifier/scroll/words), trouble (`<leader>xx/xd/xq/xs`), lualine, noice, neo-tree, tokyonight, edgy, smear-cursor, minty (`<leader>uc`), mini.hipatterns |

## External Dependencies

`stylua`, `prettierd`, `eslint_d`, `ruff`, `shellcheck`, `clang-format`, `cmakelang` and `markdownlint-cli2` are installed by Mason and are on `PATH` only inside Neovim. To run `stylua .` from a shell use `~/.local/share/jarndev.nvim/mason/bin/stylua` or install it globally (`cargo install stylua`).

System binaries that must be installed separately:

| Binary | Purpose | Install |
|--------|---------|---------|
| `mpv` | Video playback (`<leader>rv`) — launches detached in its own window | `sudo apt install mpv` |
| `chafa` | Renders the dashboard logo (`assets/logo.png`) | `sudo apt install chafa` |
| `ollama` | Local models for minuet / codecompanion (`<leader>at`, `<leader>aL`) | https://ollama.com |
| `gh` | octo.nvim issues/PR review — needs `gh auth login` | `sudo apt install gh` |
| `perf` / `valgrind` | Profiling C/C++ (`perf record`, `--tool=callgrind`) | `sudo apt install linux-tools-generic valgrind` |

## Required Setup

One-time steps the config depends on. Each of these fails **silently** — the
feature is simply absent rather than erroring — so verify them rather than
assuming.

`os-custom-config/linux/install-nvim.sh` automates steps 1 and 3 (and the apt
packages, Neovim install, clone and lazy/Mason bootstrap). It is idempotent and
supports `--check` to report without changing anything. Steps 2, 4 and 5 stay
manual: `gh auth login` is interactive, and 4/5 are per-project or optional.

### 1. Put Node on `PATH` (blocking — breaks every Node LSP)

`node` and `npm` are **lazy nvm shell functions** defined in `~/.zshrc`, and no
nvm `bin` directory is on `PATH` until one of them is called in that shell.
Neovim started from a fresh terminal (or a desktop entry) therefore cannot start
`ts_ls`, `eslint`, `jsonls`, `html`, `cssls`, `tailwindcss`, `bashls`, `yamlls`
or `dockerls` — and Mason cannot install them either (`Could not find executable
"npm" in PATH`).

Add to `~/.zshenv` — **not** `.zshrc`, so non-interactive shells get it too:

```sh
export PATH="$HOME/.nvm/versions/node/v24.15.0/bin:$PATH"
```

Verify (must print a path, not the bare word `npm`):

```sh
zsh -c 'command -v npm'
```

### 2. Authenticate the GitHub CLI (octo.nvim)

```sh
gh auth login && gh auth status
```

Without this `<leader>gp` / `<leader>gi` / `<leader>gr` open an empty picker.

### 3. Kitty pane navigation (smart-splits)

`<C-hjkl>` moves between Neovim splits with no setup. Making the *same* keys
cross into adjacent **kitty** panes needs the kitty side wired up as well.

The kittens themselves are installed automatically by the spec's `build` hook
(`./kitty/install-kittens.bash` copies three `.py` files into
`~/.config/kitty/`); re-run it with `:Lazy build smart-splits.nvim` if that
directory is ever reset.

Then add to `~/.config/kitty/kitty.conf`:

```conf
map ctrl+h neighboring_window left
map ctrl+j neighboring_window down
map ctrl+k neighboring_window up
map ctrl+l neighboring_window right

# smart-splits sets the IS_NVIM user-var on startup; unset the maps so the keys
# fall through to Neovim whenever the focused window is running it.
map --when-focus-on var:IS_NVIM ctrl+h
map --when-focus-on var:IS_NVIM ctrl+j
map --when-focus-on var:IS_NVIM ctrl+k
map --when-focus-on var:IS_NVIM ctrl+l

# 3 = resize step
map alt+h kitten relative_resize.py left  3
map alt+j kitten relative_resize.py down  3
map alt+k kitten relative_resize.py up    3
map alt+l kitten relative_resize.py right 3

map --when-focus-on var:IS_NVIM alt+h
map --when-focus-on var:IS_NVIM alt+j
map --when-focus-on var:IS_NVIM alt+k
map --when-focus-on var:IS_NVIM alt+l

# required so the kittens can drive kitty over its socket
allow_remote_control yes
listen_on unix:@mykitty
```

Notes: smart-splits must stay `lazy = false` (it sets `IS_NVIM` at startup,
which every conditional mapping above keys off), and `at_edge = 'wrap'` is
unsupported on kitty — the spec uses `'stop'`.

### 4. C/C++ project indexing (clangd)

clangd works on standalone files via `--fallback-style`, but for a real project
it wants a compilation database at the project root:

```sh
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -B build   # CMake projects
bear -- make                                       # Makefile projects (sudo apt install bear)
ln -s build/compile_commands.json .                # clangd looks in the root
```

`codelldb` (DAP) is installed by Mason automatically. The *Build & debug current
file* launch config compiles the buffer in place with `gcc`/`g++ -g -O0`, so it
needs no project setup.

### 5. Profiling (optional)

```sh
sudo apt install linux-tools-generic valgrind
perf record -g ./a.out              # then :PerfLoadFlat / :PerfAnnotate
valgrind --tool=callgrind ./a.out
```

No profiler plugin is installed by default — see `perfanno.nvim` if you want
inline per-line cost annotations. `:Lazy profile` and `Snacks.profiler` profile
*Neovim itself*, which is a different problem.

## Useful In-Editor Commands

- `:Lazy` — plugin manager UI (update, install, profile)
- `:Mason` — LSP/tool installer
- `:ConformInfo` — formatter status
- `:checkhealth` — full diagnostic health check
