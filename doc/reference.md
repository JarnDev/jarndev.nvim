# Neovim Reference

Everything this config binds, in one searchable buffer.

- `<leader>?` opens this file
- `<C-f>` fuzzy-jump to any line in this file (plugin name, key, description)
- `/` plain search, `q` or `<Esc>` closes

`<leader>` is `<Space>`. Keys marked *(buffer)* only exist in a matching buffer
(an LSP-attached file, an `http` file, a git-tracked file...).

## Contents

| Section | Covers |
| --- | --- |
| [Vim Special Keys](#vim-special-keys) | Builtin `[`/`]`, `g`, `z`, operators, marks, registers |
| [Global Keymaps](#global-keymaps) | `lua/keymaps/init.lua` — not owned by any plugin |
| [Leader Map](#leader-map) | What each `<leader>` prefix group means |
| [AI](#ai) | codecompanion, claudecode, minuet |
| [Completion](#completion) | blink.cmp, copilot.vim |
| [Database](#database) | vim-dadbod + UI + completion |
| [Editor](#editor) | which-key, dap, oil, harpoon, flash, yanky, dial, ... |
| [Formatting](#formatting) | conform.nvim |
| [Git](#git) | gitsigns, diffview, octo |
| [LSP](#lsp) | nvim-lspconfig, mason, neoconf, lazydev |
| [Testing](#testing) | neotest |
| [Treesitter](#treesitter) | parsers, textobjects, context, autotag |
| [UI](#ui) | snacks, mini, trouble, neo-tree, bufferline, noice, ... |
| [Troubleshooting](#troubleshooting) | `:checkhealth` and friends |

## Vim Special Keys

Neovim builtins. Where this config overrides one, the plugin section says so.

### Navigation `[` / `]`

| Key | Action |
| --- | --- |
| `]d` / `[d` | Next / prev diagnostic |
| `]c` / `[c` | Next / prev git hunk (gitsigns, buffer-local) |
| `]x` / `[x` | Next / prev Trouble item |
| `]f` / `[f` | Next / prev function start (treesitter) |
| `]F` / `[F` | Next / prev function end (treesitter) |
| `]C` / `[C` | Next / prev class start (treesitter) |
| `]a` / `[a` | Next / prev parameter (treesitter) |
| `]]` / `[[` | Next / prev LSP reference (snacks.words) |
| `]q` / `[q` | Next / prev quickfix item |
| `]l` / `[l` | Next / prev location list |
| `]t` / `[t` | Next / prev tag |
| `]m` / `[m` | Next / prev method start |
| `]M` / `[M` | Next / prev method end |
| `](` / `[(` | Next / prev unmatched `(` |
| `]{` / `[{` | Next / prev unmatched `{` |

### Goto `g`

| Key | Action |
| --- | --- |
| `gd` | LSP definition *(buffer)* |
| `gr` | LSP references *(buffer)* |
| `gI` | LSP implementation *(buffer)* |
| `gD` | LSP declaration *(buffer)* |
| `K` | LSP hover *(buffer)* |
| `gK` | Hover provider picker (dictionary, ...) |
| `gc` / `gcc` | Comment motion / line (context-aware, ts-comments) |
| `gs*` | mini.surround — see [mini.nvim](#mininvim) |
| `gp` / `gP` | Yanky put, cursor after the paste |
| `gf` | Open file under cursor |
| `gi` | Go to last insert position |
| `gv` | Re-select last visual selection |
| `gg` / `G` | First / last line |
| `g;` / `g,` | Prev / next change position |
| `gJ` | Join lines without space |
| `gq` | Format / wrap text |
| `g<C-a>` / `g<C-x>` | Increment/decrement as a ramp (visual, dial) |

### Fold & View `z`

| Key | Action |
| --- | --- |
| `za` | Toggle fold |
| `zo` / `zc` | Open / close fold |
| `zO` / `zC` | Open / close all folds recursively |
| `zR` / `zM` | Open all / close all folds |
| `zf` | Create fold (visual) |
| `zd` | Delete fold |
| `zz` | Centre cursor on screen |
| `zt` / `zb` | Cursor to top / bottom of screen |
| `zh` / `zl` | Scroll left / right |

### Operators `c` `d` `y`

Pair any operator with any textobject. See [mini.nvim](#mininvim) for the
treesitter-backed objects (`f`, `c`, `o`, `a`, `u`).

| Key | Action |
| --- | --- |
| `ciw` / `diw` / `yiw` | Change / delete / yank inner word |
| `caw` / `daw` / `yaw` | Change / delete / yank around word |
| `ci"` / `di"` / `yi"` | Change / delete / yank inside `"` |
| `ca"` / `da"` / `ya"` | Change / delete / yank around `"` |
| `ci(` / `di(` / `yi(` | Change / delete / yank inside `()` |
| `ci{` / `di{` / `yi{` | Change / delete / yank inside `{}` |
| `cc` / `dd` / `yy` | Change / delete / yank whole line |
| `C` / `D` | Change / delete to end of line |
| `cw` / `dw` | Change / delete word forward |

### Marks `m` `'` `` ` ``

| Key | Action |
| --- | --- |
| `ma`–`mz` | Set local mark a–z |
| `mA`–`mZ` | Set global mark A–Z |
| `'a` | Jump to line of mark a |
| `` `a `` | Jump to exact position of mark a |
| `''` | Jump back to last jump position (line) |
| ` `` ` | Jump back to last jump position (exact) |

### Registers `"` `@`

| Key | Action |
| --- | --- |
| `"ay` | Yank into register a |
| `"ap` | Paste from register a |
| `"+y` / `"+p` | Yank / paste system clipboard |
| `"0p` | Paste last yank (not delete) |
| `qa` | Record macro into register a |
| `q` | Stop recording |
| `@a` | Play macro from register a |
| `@@` | Repeat last macro |
| `:reg` | Show all registers |

Recording shows as `󰑊 @a` in the statusline (lualine).

### Find in Line `f` `F` `t` `T`

Enhanced by flash.nvim: matches are highlighted, and repeating the same key
walks forward (clever-f). See [flash.nvim](#flashnvim).

| Key | Action |
| --- | --- |
| `fx` | Jump to next `x` on line |
| `Fx` | Jump to prev `x` on line |
| `tx` | Jump just before next `x` |
| `Tx` | Jump just before prev `x` |
| `;` / `,` | Repeat f/F/t/T forward / backward |

### Replace `r` `R`

`r` in operator-pending mode is flash remote (`yriw` etc.); normal-mode `r`
is untouched.

| Key | Action |
| --- | --- |
| `rx` | Replace char under cursor with `x` |
| `R` | Enter replace mode |
| `~` | Toggle case of char |
| `g~iw` | Toggle case of word |
| `guiw` / `gUiw` | Lowercase / uppercase word |

### Overridden builtins

Keys this config took over, and what to use instead.

| Key | Was | Now |
| --- | --- | --- |
| `s` | Substitute char | flash jump — use `cl` |
| `S` | Substitute line | flash treesitter — use `cc` |
| `p` / `P` | Put | yanky put (yank ring) |
| `<C-a>` / `<C-x>` | Increment a number | dial (bools, dates, semver) |
| `<C-hjkl>` | Nothing | smart-splits window move |
| `<C-p>` / `<C-n>` | Line up / down | yank-ring cycle (after a paste) |
| `-` | Move to first non-blank of line up | Open parent dir (oil) |
| `\` | Nothing | Toggle neo-tree |
| arrow keys | Move | Disabled — nag message |

## Global Keymaps

From `lua/keymaps/init.lua`. These belong to no plugin.

| Key | Mode | Action |
| --- | --- | --- |
| `<Esc>` | n | Clear search highlight (`:nohlsearch`) |
| `<Esc><Esc>` | t | Leave terminal mode |
| `]d` / `[d` | n | Next / prev diagnostic (with float) |
| `]]` / `[[` | n, t | Next / prev LSP reference (snacks.words) |
| `<leader>?` | n | This reference |
| `<leader>rv` | n | Play video under cursor with mpv (detached window) |
| arrows | n | Disabled, echoes a reminder to use `hjkl` |

`<leader>rv` takes the path under the cursor if it resolves to a file,
otherwise it prompts with file completion.

## Leader Map

The which-key groups, i.e. what to expect after each prefix. Press the prefix
and wait to see the live menu.

| Prefix | Group |
| --- | --- |
| `<leader>a` | AI assistant (codecompanion, claudecode, minuet) |
| `<leader>c` | Code (LSP actions, refactor, docstring, neoconf) |
| `<leader>d` | Debug (dap) |
| `<leader>g` | Git (diffview, octo, gitbrowse) |
| `<leader>h` | Git hunk (gitsigns) |
| `<leader>j` | Harpoon / jump |
| `<leader>l` | Lazy utils (lazygit, lazydocker, terminal) |
| `<leader>o` | Overseer tasks |
| `<leader>q` | Quit / sessions |
| `<leader>r` | Run (HTTP requests, media) |
| `<leader>s` | Search (snacks picker) |
| `<leader>t` | Testing (neotest) |
| `<leader>u` | UI / utils |
| `<leader>w` | Workspace |
| `<leader>x` | Diagnostics (trouble, lint) |
| `<leader><Tab>` | Buffers |
| `<leader>1`–`4` | Harpoon slots |
| `<leader>H` | Home dashboard |
| `<leader>?` | This reference |

## AI

### codecompanion.nvim

Chat and inline assistant against the Anthropic API. Default model
`claude-sonnet-4-6`; an `ollama` adapter (`qwen2.5-coder:14b`) is configured as
a fully local alternative.

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>aa` | n, v | Toggle chat window |
| `<leader>ai` | n, v | Inline assistant (edits the buffer in place) |
| `<leader>ac` | v | Add the visual selection to the chat |
| `<leader>ap` | n, v | Action palette |
| `<leader>aL` | n, v | Chat against the **local** Ollama adapter |

Needs `ANTHROPIC_API_KEY` in the environment for the cloud adapter, and a
running `ollama` for `<leader>aL`. Help: `:h codecompanion`.

### claudecode.nvim

Runs the Claude Code CLI in a Neovim terminal and wires the current buffer /
selection into it.

| Key | Action |
| --- | --- |
| `<leader>aT` | Open the Claude Code terminal (`:ClaudeCode`) |
| `<leader>af` | Focus the existing Claude Code terminal |

### minuet-ai.nvim

Local FIM completion via Ollama (`qwen2.5-coder:7b` at
`localhost:11434`). Deliberately **off** by default so it never fights
copilot.vim's ghost text.

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>at` | n | Toggle ghost-text engine: Copilot ⇄ local Ollama |
| `<A-y>` | i | Accept the suggestion *(local engine on)* |
| `<A-Y>` | i | Accept one line |
| `<A-[>` / `<A-]>` | i | Previous / next suggestion |
| `<A-e>` | i | Dismiss |

`<leader>at` flips `vim.g.ai_engine_local`, which also decides whether blink.cmp
queries the `minuet` source — so when it is off, nothing hits localhost on every
keystroke. Budget: 1 completion per request, 512-char context, 4s timeout.

## Completion

### blink.cmp

The completion engine (not nvim-cmp). Sources in priority order:
`lsp`, `path`, `snippets`, `buffer`, `copilot`, plus `minuet` when the local AI
engine is toggled on, and `dadbod` instead of everything in `sql`/`mysql`.

| Key | Mode | Action |
| --- | --- | --- |
| `<Tab>` | i | Jump snippet forward, else accept, else fall through |
| `<S-Tab>` | i | Jump snippet backward |
| `<CR>` | i | **Fall through** — newline, never accept |
| `<C-n>` / `<C-p>` | i | Next / previous item (default preset) |
| `<C-e>` | i | Cancel |
| `<C-space>` | i | Open menu / documentation |

`<CR>` is intentionally not an accept key: use `<Tab>`. Docs auto-open after
200 ms, and accepting a function adds its brackets. Help: `:h blink-cmp`.

### copilot.vim

Inline ghost text from GitHub Copilot, and a blink source (scored above LSP at
`+100`).

| Key | Mode | Action |
| --- | --- | --- |
| `<M-l>` | i | Accept the ghost-text suggestion |

`<Tab>` belongs to blink, so `copilot_no_tab_map` is set and `<M-l>` is the
accept key. Run `:Copilot setup` once. Toggle it off in favour of the local
model with `<leader>at`.

## Database

### vim-dadbod + dadbod-ui + dadbod-completion

A SQL client inside Neovim. The drawer opens on the **right**, 30 columns wide.

| Command | Action |
| --- | --- |
| `:DBUIToggle` | Open / close the connection drawer |
| `:DBUI` | Open the drawer |
| `:DBUIAddConnection` | Add a connection URL |
| `:DBUIFindBuffer` | Attach the current buffer to a connection |
| `:DBUIRenameBuffer` | Rename the current query buffer |
| `:DBUILastQueryInfo` | Timing / row count of the last query |

In the drawer: `o` or `<CR>` expands, `S` opens in a split, `d` deletes,
`R` refreshes. In a `.sql` buffer, `<leader>W` saves the query and blink
completes table and column names. Help: `:h dadbod-ui`.

## Editor

### which-key.nvim

The live keymap menu. Press any prefix (`<leader>`, `g`, `z`, `[`, `]`, `"`) and
pause — the menu lists what can follow. `:WhichKey` shows everything.
This is the fastest way to discover a key you half-remember.

### flash.nvim

Jump to any visible position by typing 1–2 characters and then a label.
Configured with upstream defaults (`opts = {}`).

| Key | Mode | Action |
| --- | --- | --- |
| `s` | n, x, o | Jump — labels every match on screen, both directions |
| `S` | n, x, o | Treesitter select — labels syntax nodes, `;`/`,` grow/shrink |
| `r` | o | Remote — operate on a distant object (`yriw`) then return |
| `R` | o, x | Treesitter search — search + node labels |

Search range is the **visible viewport** of every window, not the whole file.
`f`/`F`/`t`/`T` get highlighting and clever-f repeat, but no labels.
`/` and `?` are *not* enhanced (`modes.search.enabled = false` and no toggle key
is bound). Labels are `asdfghjkl…`, assigned nearest-cursor-first; extra matches
stay highlighted without a label until you narrow the pattern.
mini.surround moved to `gs*` so bare `s` has no `timeoutlen` delay.

### oil.nvim

Edit the filesystem like a buffer: rename by editing a line, delete with `dd`,
create by adding a line, then `:w` to apply.

| Key | Action |
| --- | --- |
| `-` | Open the parent directory of the current file |
| `<CR>` | Open the entry under the cursor |
| `g?` | Show all oil mappings |

Hidden files are shown. This is the "operate on files" tool; neo-tree is the
"see the tree" tool.

### harpoon2

Pin a few files and reach them by slot — muscle memory, not search.

| Key | Action |
| --- | --- |
| `<leader>ja` | Add the current file to the list |
| `<leader>jj` | Toggle the quick menu (edit the list as a buffer) |
| `<leader>jn` / `<leader>jp` | Next / previous file in the list |
| `<leader>1`–`<leader>4` | Jump straight to slot 1–4 |

### yanky.nvim

A yank ring on top of `p`/`P`.

| Key | Mode | Action |
| --- | --- | --- |
| `p` / `P` | n, x | Put after / before |
| `gp` / `gP` | n, x | Put, leaving the cursor after the pasted text |
| `<C-p>` / `<C-n>` | n | **Right after a paste**: cycle to older / newer yank |
| `<leader>p` | n | Pick from the whole yank history |

The ring persists across sessions via shada, and puts flash briefly (200 ms).
Loaded on `VeryLazy` rather than on `p`, because the ring is built from
`TextYankPost` — lazy-loading on paste would drop every yank made before the
first paste.

### dial.nvim

`<C-a>`/`<C-x>` that understand more than integers.

| Key | Mode | Action |
| --- | --- | --- |
| `<C-a>` / `<C-x>` | n | Increment / decrement under cursor |
| `<C-a>` / `<C-x>` | v | Increment / decrement each selected line |
| `g<C-a>` / `g<C-x>` | v | Ramp: +1, +2, +3 … down the selection |

Knows: decimal (incl. negative) and hex integers, `true`/`false`,
`True`/`False`, `and`/`or`, `&&`/`||`, single letters, `%Y-%m-%d`, `%Y/%m/%d`,
`%H:%M`, and semver (bumping a semver keeps the other fields intact).

### smart-splits.nvim

Window movement and resizing that can cross into adjacent kitty panes.

| Key | Action |
| --- | --- |
| `<C-h/j/k/l>` | Move focus left / down / up / right |
| `<A-h/j/k/l>` | Resize the split left / down / up / right |

Inside Neovim this needs no setup. Crossing into a kitty pane also needs the
kitty side wired up — see "Required Setup" in `CLAUDE.md`. At the outermost edge
it stops (kitty does not support `at_edge = 'wrap'`). neo-tree and the dashboard
are ignored. Must stay non-lazy: it sets kitty's `IS_NVIM` var at startup.

### nvim-dap + dap-ui + virtual-text

Step debugger. Adapters are installed by mason-nvim-dap: `python`, `codelldb`
(C/C++), `js-debug-adapter`.

| Key | Action |
| --- | --- |
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue / start |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dr` | Toggle REPL |
| `<leader>dl` | Run last |
| `<leader>dt` | Terminate |
| `<leader>du` | Toggle the debug UI |

Variable values appear inline as virtual text while stopped. The REPL docks to
the bottom via edgy.

**Note:** `hand_written_configs = false` in `debug.lua` — this file's own
Python/JS/C configurations are currently disabled so that autodap owns every
adapter. Flip it to `true` to restore them.

### autodap.nvim

Zero-config debugging over nvim-dap (a local plugin, resolved from `~/git` via
lazy's `dev` path, falling back to GitHub).

| Key | Action |
| --- | --- |
| `<F5>` | Detect the target and continue |
| `<leader>dC` | Same, via leader |
| `:AutodapContinue` | Command form |
| `:AutodapReset` | Forget the detected configuration |

Loads on any filetype it handles (js/ts/tsx, python, c/cpp, objc, cuda), so a
plain `<leader>dc` lists its targets too.

### refactoring.nvim

Treesitter refactorings that LSP rename cannot do.

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>cr` | n, x | Pick a refactor (extract function / variable, inline) |
| `<leader>cR` | n, x | Insert a debug print for the variable under cursor |

### neogen

| Key | Action |
| --- | --- |
| `<leader>cd` | Generate a docstring for the function/class under the cursor |

JSDoc, Google-style Python, Doxygen for C/C++, etc., driven by treesitter and
filled in as a LuaSnip snippet — `<Tab>` between the fields.

### inc-rename.nvim

LSP rename with a live preview of every call site as you type. Bound as
`<leader>cn` in the LSP section; `:IncRename <newname>` is the command form.

### grug-far.nvim

Project-wide search and replace in a buffer you edit and then apply.

| Key | Action |
| --- | --- |
| `<leader>S` | Open search & replace |
| `<leader>sR` | Same, prefilled with the word under cursor |

The panel docks right at 40% width (edgy).

### overseer.nvim

Task runner with a results list wired into the quickfix.

| Key | Action |
| --- | --- |
| `<leader>oo` | Toggle the task list |
| `<leader>or` | Run a task |
| `<leader>oa` | Pick a task, then an action on it (restart, stop, open output) |
| `<leader>oi` | Overseer health (`:checkhealth overseer`) |

The list docks to the bottom at 30% height.

### kulala.nvim

An HTTP client: write requests in a `.http` file and run them in place. All keys
are `http`-filetype only.

| Key | Action |
| --- | --- |
| `<leader>rr` | Run the request under the cursor |
| `<leader>rR` | Run every request in the file |
| `<leader>re` | Select the environment |
| `<leader>ri` | Inspect the request that would be sent |

### nvim-lint

Linters that are not language servers, run on `BufEnter`, `BufWritePost` and
`InsertLeave`.

| Filetype | Linter |
| --- | --- |
| markdown | markdownlint-cli2 |
| python | ruff |
| javascript / typescript (+ react) | eslint_d |

| Key | Action |
| --- | --- |
| `<leader>xL` | Lint the buffer now |

Results land in the normal diagnostics, so `]d`, `<leader>xx` and the
bufferline counters all pick them up.

### hover.nvim

| Key | Action |
| --- | --- |
| `K` | LSP hover *(buffer, set on LspAttach)* |
| `gK` | Choose a hover provider (LSP, dictionary) |
| mouse hover | Hover after 1 s (`mousemoveevent` is on) |

`K` is pinned to `vim.lsp.buf.hover` in any LSP buffer so hover.nvim's provider
cycling never shadows it.

### auto-session

Saves and restores the session per directory. Suppressed in `~`, `~/Downloads`,
`/` and `/tmp`.

| Key | Action |
| --- | --- |
| `<leader>qs` | Search sessions |
| `<leader>qd` | Delete a session |

Neo-tree is closed before saving and reopened after restoring, so the tree does
not come back as an empty window.

### nvim-autopairs

Inserts the closing bracket/quote as you type, treesitter-aware (it will not
pair inside a Lua string or a JS template literal).

| Key | Mode | Action |
| --- | --- | --- |
| `<M-e>` | i | Fast-wrap: surround the next object with the pair being typed |

### ts-comments.nvim

No keys. It fixes `commentstring` per cursor context, so builtin `gc`/`gcc`
emits `{/* … */}` inside JSX instead of `// …` — likewise for `<script>` and
`<style>` blocks in vue/svelte/html.

### render-markdown.nvim

No keys. Renders markdown in the buffer: heading icons, bulleted glyphs,
checkboxes and block-styled code fences. Active in `markdown` filetypes — this
file included.

### markdown-preview.nvim

| Key | Action |
| --- | --- |
| `<leader>mp` | Toggle a live browser preview *(markdown only)* |

### vim-sleuth

No keys, no config. Detects `shiftwidth`/`expandtab` from the file and its
neighbours, so you inherit each project's indentation automatically.

## Formatting

### conform.nvim

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>f` | all | Format the buffer (async, LSP fallback) |

Also formats on save with a 500 ms timeout. `:ConformInfo` shows which formatter
resolved for the current buffer and whether its binary was found.

| Filetype | Formatter |
| --- | --- |
| lua | stylua |
| c, cpp | clang-format (LLVM style unless the project ships `.clang-format`) |
| cmake | cmake_format |
| python | ruff_format + ruff_organize_imports |
| js, ts, jsx, tsx, json, jsonc, html | prettierd |
| css, scss, yaml, markdown, graphql | prettierd |

Formatters are Mason-installed, so they are on `PATH` only inside Neovim.

## Git

### gitsigns.nvim

Signs in the gutter plus hunk-level staging. All keys are buffer-local to a
git-tracked file.

| Key | Mode | Action |
| --- | --- | --- |
| `]c` / `[c` | n | Next / previous hunk |
| `<leader>hs` | n, v | Stage hunk (visual: stage the selected lines) |
| `<leader>hr` | n, v | Reset hunk |
| `<leader>hS` | n | Stage the whole buffer |
| `<leader>hu` | n | Undo stage hunk |
| `<leader>hR` | n | Reset the whole buffer |
| `<leader>hp` | n | Preview the hunk in a float |
| `<leader>hb` | n | Blame this line (full) |
| `<leader>hB` | n | Toggle inline blame on every line |
| `<leader>hd` | n | Diff this file against the index |
| `<leader>hD` | n | Diff this file against `HEAD~` |
| `<leader>ht` | n | Toggle showing deleted lines |

Signs: `+` add, `~` change, `_` delete, `‾` top-delete.

### diffview.nvim

| Key | Action |
| --- | --- |
| `<leader>gd` | Diff the working tree |
| `<leader>gh` | File history of the current file |
| `<leader>gH` | History of the whole repo |
| `<leader>gc` | Close the diffview tab |

Inside a diffview: `<Tab>`/`<S-Tab>` cycle files, `g?` lists all mappings.

### octo.nvim

GitHub issues and PR review in Neovim, using the snacks picker.

| Key | Action |
| --- | --- |
| `<leader>gp` | List pull requests |
| `<leader>gi` | List issues |
| `<leader>gr` | Start a review on the current PR |
| `<leader>gO` | Octo action palette |

**Requires `gh auth login`.** Without it these open an empty picker with no
error. Verify with `gh auth status`.

### Git elsewhere

| Key | Action |
| --- | --- |
| `<leader>lg` | Lazygit (snacks) |
| `<leader>gB` | Open the current line/selection on the git host in a browser |

## LSP

### nvim-lspconfig + mason

Keys are buffer-local, set on `LspAttach`. Navigation goes through the snacks
picker, call hierarchy through trouble.

| Key | Mode | Action |
| --- | --- | --- |
| `gd` | n | Goto definition |
| `gr` | n | Goto references (`nowait` — beats builtin `gr*`) |
| `gI` | n | Goto implementation |
| `gD` | n | Goto declaration |
| `K` | n | Hover |
| `<leader>D` | n | Type definition |
| `<leader>ds` | n | Document symbols |
| `<leader>ws` | n | Workspace symbols |
| `<leader>cn` | n | Rename, with live preview (inc-rename) |
| `<leader>ca` | n, x | Code action |
| `<leader>ci` | n | Incoming calls — "who calls this?" |
| `<leader>co` | n | Outgoing calls — "what does this call?" |
| `<leader>ch` | n | Toggle inlay hints *(if the server supports them)* |

References under the cursor highlight on `CursorHold`.

Servers: `lua_ls`, `ts_ls`, `jsonls`, `html`, `cssls`, `tailwindcss`, `eslint`,
`pyright`, `marksman`, `bashls`, `yamlls`, `taplo`, `dockerls`, `clangd`,
`cmake`.

clangd runs with `--clang-tidy`, `--background-index` and
`--header-insertion=iwyu`. It reads `compile_commands.json` at the project root;
without one it falls back to LLVM style. Generate it with
`cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -B build` or `bear -- make`.

**The two Mason installers take different name spaces.** `mason-lspconfig` takes
lspconfig server names (`lua_ls`); `mason-tool-installer` takes Mason package
names (`lua-language-server`). Passing the wrong kind makes it silently skip the
package. Standalone tools installed that way: stylua, markdownlint-cli2,
prettierd, eslint_d, tree-sitter-cli, shellcheck, clang-format, cmakelang.

`:Mason` to browse/install, `:LspInfo` for what attached, `:checkhealth lsp`
when a server does not start.

### neoconf.nvim

| Key | Action |
| --- | --- |
| `<leader>cN` | Open the project settings UI (`:Neoconf`) |

Per-project LSP and plugin settings from `.neoconf.json`. Set up *before* any
`vim.lsp.config()` call, otherwise project overrides are ignored.

### lazydev.nvim

No keys. Loads Neovim and `vim.uv` type definitions into `lua_ls` while editing
Lua — this is why editing this config gets completion for `vim.api.*`.

### fidget.nvim

No keys. The LSP progress spinner in the bottom right.

## Testing

### neotest

Adapters: `neotest-python` and `neotest-jest` (via `npx jest`, with `CI=true`).

| Key | Action |
| --- | --- |
| `<leader>tt` | Run the nearest test |
| `<leader>tf` | Run every test in the file |
| `<leader>td` | Debug the nearest test (through dap) |
| `<leader>ts` | Toggle the summary tree |
| `<leader>to` | Open the output of the last run |

Results appear as virtual text next to each test, output opens automatically on
run, and failures go to `Trouble quickfix` rather than the plain quickfix.

## Treesitter

### nvim-treesitter (`main` branch)

No keys — it installs parsers, and Neovim's builtin treesitter drives
highlighting and indentation. Missing parsers install asynchronously at startup,
and opening a new filetype auto-installs its parser.

`:TSUpdate` to update parsers, `:checkhealth nvim-treesitter` to inspect.
Needs the `tree-sitter` CLI, which Mason installs.

### nvim-treesitter-textobjects

Motions and swaps. Class motions use **capitals** because `]c`/`[c` are
gitsigns' hunk motions and `]]`/`[[` are snacks.words.

| Key | Mode | Action |
| --- | --- | --- |
| `]f` / `[f` | n, x, o | Next / previous function start |
| `]F` / `[F` | n, x, o | Next / previous function end |
| `]C` / `[C` | n, x, o | Next / previous class start |
| `]a` / `[a` | n, x, o | Next / previous parameter |
| `<leader>cA` | n | Swap the parameter with the next one |
| `<leader>cP` | n | Swap the parameter with the previous one |

Motions set the jumplist, and selection looks ahead to the next object if the
cursor is not inside one. This plugin also ships the queries that mini.ai reads,
which is why it is loaded eagerly.

### nvim-treesitter-context

No keys. Pins up to 3 lines of enclosing context (function/class signature) to
the top of the window when the opening line scrolls away.

### nvim-ts-autotag

No keys. Closes and renames HTML/JSX tags as you type: type `<div>` and the
`</div>` appears; rename one and the pair follows.

## UI

### snacks.nvim

The largest single dependency here — picker, dashboard, terminal, lazygit,
indent guides, notifier, scroll animation, word highlighting, images.

#### Picker

| Key | Mode | Action |
| --- | --- | --- |
| `<leader><leader>` | n | Open buffers |
| `<leader>/` | n | Fuzzy-find lines in this buffer |
| `<leader>sf` | n | Files |
| `<leader>sg` | n | Grep the project |
| `<leader>sw` | n, x | Grep the word/selection under cursor |
| `<leader>s/` | n | Grep only open buffers |
| `<leader>s.` | n | Recent files |
| `<leader>sp` | n | Projects |
| `<leader>sn` | n | Files in the Neovim config |
| `<leader>sh` | n | Help tags |
| `<leader>sk` | n | Keymaps — every active mapping, searchable |
| `<leader>sd` | n | Diagnostics |
| `<leader>sr` | n | Resume the last picker |
| `<leader>ss` | n | List every available picker |

Inside a picker: `<C-n>`/`<C-p>` or `<Down>`/`<Up>` move, `<CR>` confirms,
`<C-s>`/`<C-v>` open in a split/vsplit, `<C-t>` in a tab, `<Tab>` multi-selects,
`<Esc>` closes, `?` shows the picker's own keymap.

`<leader>sk` is the ground truth for "what is this key bound to" — it reads the
live mappings, so it never drifts from the config the way this file can.

#### Terminals, git and dashboard

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>lt` | n | Floating terminal |
| `<leader>lg` | n | Lazygit |
| `<leader>ld` | n | Lazydocker |
| `<leader>gB` | n, v | Open the current line on the git host in a browser |
| `<leader>H` | n | Back to the dashboard |

Dashboard keys: `f` files, `p` projects, `r` recent, `c` config, `w` grep,
`l` Lazy, `q` quit. The JarnDev logo renders as a real image through the kitty
graphics protocol, falls back to `chafa` block art, then to ASCII.

#### Passive modules

No keys, always on: `indent` guides; `notifier` (toast messages); `bigfile`
(disables heavy features in huge files); `scroll` (smooth scrolling, off in
neo-tree); `words` (highlights the symbol under the cursor — this is what
`]]`/`[[` walk); `image` (inline images in kitty-class terminals).

### mini.nvim

Four modules are enabled; `mini.statusline` and `mini.tabline` are deliberately
off in favour of lualine and bufferline.

#### mini.ai

Textobjects backed by the treesitter queries. Note `f` is the function
**definition**, not the call.

| Object | Selects |
| --- | --- |
| `af` / `if` | A function definition / its body |
| `ac` / `ic` | A class / its body |
| `ao` / `io` | A conditional or loop / its body |
| `aa` / `ia` | A parameter (with comma) / the parameter alone |
| `au` / `iu` | A function **call** / its arguments |

Use with any operator: `vaf`, `dif`, `cia`, `yic`. Searches within 500 lines.

#### mini.surround

Prefixed `gs` so bare `s` stays free for flash.

| Key | Action |
| --- | --- |
| `gsa` | Add surround (`gsaiw"` wraps a word in quotes) |
| `gsd` | Delete surround (`gsd"`) |
| `gsr` | Replace surround (`gsr"'`) |
| `gsf` / `gsF` | Find the surround right / left |
| `gsh` | Highlight the surround |
| `gsn` | Change how many lines it searches |

#### mini.move

Move the selection or line with `<M-D-h/j/k/l>`, reindenting linewise moves.
(Needs a terminal that sends Meta+Cmd; mostly inert on Linux.)

#### mini.hipatterns

No keys. Paints `#rrggbb` colours inline with the colour itself.

### trouble.nvim

A list for everything that produces locations.

| Key | Action |
| --- | --- |
| `<leader>xx` | Workspace diagnostics |
| `<leader>xd` | Diagnostics for this buffer only |
| `<leader>xq` | Quickfix list |
| `<leader>xl` | Location list |
| `<leader>xs` | **Symbol outline** of the current file |
| `]x` / `[x` | Next / previous item (jumps, skipping group headers) |

`<leader>xs` is the outline — aerial.nvim and outline.nvim are deliberately not
installed. Trouble also backs `<leader>ci`/`<leader>co` (call hierarchy) and has
a `profiler` mode. Docks to the bottom at 35% height.

### neo-tree.nvim

The file tree (the persistent sidebar; oil is the buffer-style editor).

| Key | Action |
| --- | --- |
| `\` | Toggle the tree at the project root |
| `<leader>E` | Toggle the tree at the cwd |

Inside the tree: `<CR>` opens — **or plays the file with mpv** if it is a video
(mp4/mkv/avi/mov/webm/flv/wmv/m4v); `a` add, `d` delete, `r` rename, `c` copy,
`x` cut, `p` paste, `H` toggle hidden, `?` show all mappings.
`<Space>` is unmapped so it stays the leader key.

Sources: filesystem, buffers, git_status, document_symbols. Dotfiles and
gitignored files are visible. Pinned left at 34 columns by edgy.

### bufferline.nvim

The tab-like buffer bar, with LSP diagnostic counts per buffer.

| Key | Action |
| --- | --- |
| `<leader><Tab>d` | Close the current buffer (keeps the window layout) |
| `<leader><Tab>u` | Reopen the last closed buffer |
| `<leader><Tab>U` | Pick a recent file to reopen |
| `<leader><Tab>p` | Pick a buffer by letter |
| `<leader><Tab>P` | Pin / unpin the current buffer |

### lualine.nvim

No keys. The statusline (global, one for all windows): mode, branch, diff,
diagnostics, path, macro-recording indicator, attached LSP servers, encoding,
fileformat, filetype, progress, location.

### noice.nvim

No keys. Replaces the message area, cmdline and popupmenu. The command line
appears centred, search at the bottom, long messages open in a split. Undo/redo
and write messages are routed to a small corner view. `:Noice` opens the message
history, `:Noice dismiss` clears what is on screen.

### edgy.nvim

Docks sidebars into fixed slots so trouble, overseer, dap-ui and neo-tree stop
fighting for space.

| Key | Action |
| --- | --- |
| `<leader>ue` | Toggle the docked sidebars |

Bottom: quickfix, trouble (35%), overseer (30%), help (40%), snacks terminal,
dap-repl. Left: neo-tree (34 cols). Right: grug-far (40%). Animation is off,
since snacks.scroll already animates.

### nvim-window-picker

| Key | Action |
| --- | --- |
| `<leader>wp` | Pick a window by letter and focus it |

Shows one big floating letter per window. Also what neo-tree's
`open_with_window_picker` mappings use. Skips the current window and
auto-selects when only one candidate remains.

### nvzone (minty, menu, volt)

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>uc` | n | Colour picker (`:Huefy`) |
| `<leader>uC` | n | Colour shades (`:Shades`) |
| `<RightMouse>` | n, v | Context menu at the cursor |

The right-click menu is filetype-aware: it shows the neo-tree menu inside the
tree and a general one elsewhere. `volt` is the shared rendering library both
need and has no UI of its own.

### todo-comments.nvim

No keys. Highlights `TODO:`, `FIXME:`, `HACK:`, `NOTE:`, `WARN:`, `PERF:` and
`TEST:` in comments (signs off, so the gutter stays for git and diagnostics).
`:TodoTrouble` lists them all, `:TodoQuickFix` sends them to the quickfix.

### tokyonight.nvim

No keys. `tokyonight-night` with the JarnDev brand palette applied on top:
background `#07080b`, foreground `#f4f6fb`, cyan `#22d3ee`, purple `#8b7cff`,
green `#7cff9b`, amber `#fbbf24`. Comments are un-italicised, and the dashboard
header is repainted to the foreground colour so the logo is not cyan.

### smear-cursor.nvim

No keys. Animates the cursor as a trail between positions, including across
buffers and neighbouring lines. Disabled on the dashboard.

### vim-startuptime

| Key | Action |
| --- | --- |
| `<leader>us` | Profile startup (`:StartupTime`, 10 runs averaged) |

Profiles **Neovim's own** startup. For plugin-level timings use `:Lazy profile`;
for runtime profiling of a slow operation use Trouble's `profiler` mode.

## Troubleshooting

| Command | When |
| --- | --- |
| `:checkhealth` | Anything unexplained — run this first |
| `:Lazy` | Plugin not loading; `U` updates, `X` cleans, `P` profiles |
| `:Mason` | A server or tool is missing; `i` installs, `X` uninstalls |
| `:LspInfo` | No completion or `gd` — is a client attached? |
| `:ConformInfo` | Format on save did nothing |
| `:Noice` | A message flashed past |
| `<leader>sk` | "What is this key bound to?" — live, never stale |
| `:messages` | The raw message history |

**Silent failures to check for** (each removes a feature without an error):

- Node not on `PATH` → every Node-based LSP is absent. Test with
  `zsh -c 'command -v npm'`; it must print a path.
- `gh auth login` not done → octo pickers are empty.
- kitty.conf not wired → `<C-hjkl>` stops at the Neovim edge instead of
  crossing into the next pane.
- No `compile_commands.json` → clangd works per-file but not project-wide.
- `chafa` / `mpv` not installed → the dashboard logo and `<leader>rv` do nothing.

Full setup instructions are in `CLAUDE.md` under "Required Setup"; the
`os-custom-config/linux/install-nvim.sh --check` script reports on most of them.
