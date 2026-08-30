# Plugin guide

The README lists every plugin and every keymap. This file answers the questions a list
cannot: **why is this here, what problem does it solve, and how do I actually use it.**

It covers the plugins added on top of the original Kickstart base. The rest of the
stack — LSP, completion, treesitter, git, formatting, testing — is described in the
README and in `CLAUDE.md`.

## Configuring any of them

Every plugin is one file returning a [lazy.nvim](https://lazy.folke.io) spec:

```text
lua/plugins/config/<category>/<name>.lua
```

Change its `opts` table and restart. `:Lazy` shows load status and timings, `:Lazy profile`
shows what each one costs at startup. Nothing here reads a separate config file — the spec
*is* the configuration, which is why every entry below names the file instead of a setting.

Per-project overrides go in a `.neoconf.json` at the project root (see **neoconf**).

---

## Navigation

### harpoon2 — `editor/harpoon.lua`

Pins a handful of files and jumps between them by slot number. This is deliberately *not*
a replacement for `<leader><leader>` (the buffer picker): the picker is a search, harpoon
is muscle memory. When you are cycling between four files for an hour, searching for them
by name every time is the wrong tool.

| Key | Action |
| --- | --- |
| `<leader>ja` | Add the current file to the list |
| `<leader>jj` | Open the quick menu (edit or reorder the list) |
| `<leader>jn` / `<leader>jp` | Next / previous pinned file |
| `<leader>1`–`<leader>4` | Jump straight to slot 1–4 |

The list is per project directory. Add files as you start working on them and forget the
picker for the rest of the session.

### smart-splits — `editor/smart-splits.lua`

Replaces the raw `<C-w>` window commands. `<C-hjkl>` moves focus, `<A-hjkl>` resizes.

The reason it exists rather than plain `<C-w>` mappings: the *same* keys can continue past
the edge of Neovim into the surrounding terminal multiplexer's panes, so you stop having
two different muscle memories for "move left". Inside Neovim alone it behaves exactly like
`<C-w>h`, so nothing is lost if you never set the terminal side up.

Crossing into kitty or tmux panes needs configuration on that side too — see **Required
Setup** in `CLAUDE.md`. Without it the keys degrade silently to plain window navigation.

Two constraints worth knowing before editing the spec: it must stay `lazy = false`, because
it sets kitty's `IS_NVIM` variable at startup and every conditional mapping keys off that;
and `at_edge = 'wrap'` is unsupported on kitty, so the spec uses `'stop'`.

### window-picker — `ui/window-picker.lua`

`<leader>wp` overlays a big letter on each window; press the letter to jump there. Useful
when a four-way split makes directional movement ambiguous.

It also silently powers neo-tree: neo-tree ships `open_with_window_picker` mappings by
default, but they are inert unless this plugin is installed. Installing it makes "open this
file — but in *that* window" work from the tree.

---

## Code

### nvim-treesitter-textobjects — `treesitter/textobjects.lua`

The most consequential addition here, because it changes what `vaf` and friends select.

It has two consumers. First, `mini.ai` reads the `textobjects.scm` queries this plugin
ships, which is what turns mini.ai's textobjects syntax-aware: `f` becomes the function
*definition* (`vaf`, `vif`), `c` a class, `o` a conditional or loop, `a` a parameter, and
`u` keeps mini.ai's original function-*call* object. Second, it provides motions:

| Motion | Jumps to |
| --- | --- |
| `]f` / `[f` | Next / previous function start |
| `]F` / `[F` | Next / previous function end |
| `]C` / `[C` | Next / previous class |
| `]a` / `[a` | Next / previous parameter |
| `<leader>cA` / `<leader>cP` | Swap the parameter under the cursor with the next / previous |

Class motions use capitals because `]c`/`[c` are gitsigns' hunk motions, which are
buffer-local and would win anyway.

Loaded eagerly (`lazy = false`) on purpose: mini.ai resolves these queries at the moment
you press `vaf`, so the runtimepath entry has to already exist.

### refactoring.nvim — `editor/refactoring.lua`

The refactorings LSP rename cannot do: extract function, extract variable, inline variable.
Treesitter-based, so it works in any language with a parser installed rather than depending
on a server implementing the code-action.

- `<leader>cr` (normal or visual) — pick a refactoring. Select the code in visual mode first
  for the extract operations.
- `<leader>cR` — insert a debug print of the variable under the cursor.

It needs `lewis6991/async.nvim` as a hard runtime dependency. That is missing from the
plugin's own spec, and without it the plugin fails at load with `module 'async' not found`.

### neogen — `editor/neogen.lua`

`<leader>cd` generates a docstring for the function or class under the cursor, in the
convention of the language: JSDoc, Google-style Python, Doxygen for C/C++. Uses LuaSnip,
which blink.cmp already pulls in, so it costs no extra dependency.

### ts-comments.nvim — `editor/ts-comments.lua`

No keymaps — it fixes the builtin `gc`/`gcc`. Neovim picks one `commentstring` per file
type, so commenting inside JSX produced `// ...` instead of `{/* ... */}`. This makes the
comment string context-aware, which matters anywhere a file embeds another language: JSX,
Vue and Svelte blocks, `<script>`/`<style>` in HTML.

If `gc` has ever produced a broken comment for you, this is the fix.

### neoconf.nvim — `lsp/neoconf.lua`

Per-project LSP and plugin settings via a `.neoconf.json` at the project root. Use it when
one repository needs different server settings from your global ones — a different Python
interpreter, stricter or looser diagnostics, a project-specific schema.

`<leader>cN` opens the settings UI, which shows what is currently in effect and where it
came from.

One hard ordering constraint: neoconf must be set up **before** any `vim.lsp.config()`
call. That is why it is a dependency of nvim-lspconfig and why `require('neoconf').setup{}`
is the first line of that spec's config function. Moving it breaks project settings silently.

---

## Workflow

### overseer.nvim — `editor/overseer.lua`

A task runner. Build, watch, lint and test commands run as managed tasks with a results
panel, and their output feeds the quickfix list, so `:cnext` walks the errors.

| Key | Action |
| --- | --- |
| `<leader>or` | Run a task |
| `<leader>oo` | Toggle the task list |
| `<leader>oa` | Quick action on a task (restart, stop, open output) |
| `<leader>oi` | Task info |

It discovers tasks from what the project already has — npm scripts, Makefile targets — so
in most repositories `<leader>or` gives you a useful list with no configuration at all.

### octo.nvim — `git/octo.lua`

GitHub issues and pull-request review inside the editor: read a PR diff, leave line
comments, submit a review, without a browser.

| Key | Action |
| --- | --- |
| `<leader>gp` | Pull request list |
| `<leader>gi` | Issue list |
| `<leader>gr` | Start a review on the current PR |
| `<leader>gO` | Action palette (everything else) |

Requires the `gh` CLI on `PATH` **and** `gh auth login`. Without authentication the pickers
open empty rather than erroring, so if `<leader>gp` shows nothing, check `gh auth status`
first.

Configured with `picker = 'snacks'` so it reuses the picker this config already has instead
of dragging telescope in as a second one.

### yanky.nvim — `editor/yanky.lua`

Gives `p` and `P` a yank ring — a history of what you copied, not just the last thing.

The workflow: paste with `p` as usual, then press `<C-p>` to replace that paste with the
previous yank, again for the one before it. `<C-n>` goes the other way. `<leader>p` opens
the full history in a picker when you want to choose directly rather than cycle.

`gp` / `gP` paste and leave the cursor *after* the pasted text, which is what you want when
pasting several things in a row.

The ring persists across sessions via shada. It loads on `VeryLazy` rather than on `p`,
because the ring is built from `TextYankPost` — lazy-loading on paste would silently drop
every yank made before the first paste of the session.

### dial.nvim — `editor/dial.lua`

Extends `<C-a>` / `<C-x>` (increment / decrement) past plain integers. The explicit augend
group in the spec is the entire reason to install this — without it the plugin adds nothing
over the builtin.

What the configured group handles:

- integers, including negatives, and hex
- `true` ↔ `false`, `True` ↔ `False`, `and` ↔ `or`, `&&` ↔ `||`
- dates (`%Y-%m-%d`, `%Y/%m/%d`) and times (`%H:%M`)
- semver — `<C-a>` on the patch of `1.2.3` gives `1.2.4`
- single letters, `a` → `b`

In visual mode `<C-a>` bumps every match in the selection; `g<C-a>` ramps them, turning a
column of `1 1 1` into `1 2 3`.

Add your own pairs by extending the `default` group in the spec — the
`augend.constant.new { elements = { 'foo', 'bar' } }` pattern at the bottom is the template.

### mini.hipatterns — `ui/mini.lua`

Highlights patterns inline: color codes like `#ff0000` are shown in their actual color, and
`TODO`/`FIXME`/`HACK`/`NOTE` tags get a highlight. No keymaps — it is passive.

Complements todo-comments, which handles the *searching* side. That plugin binds no keys
here, but registers `:TodoTrouble`, `:TodoQuickFix` and `:TodoLocList` to list every tag in
the project.

---

## UI

### edgy.nvim — `ui/edgy.lua`

Docks sidebar and bottom windows into fixed slots so trouble, overseer, dap-ui, neo-tree
and terminals stop fighting each other for space. Without it, opening a second panel
resizes or displaces the first one unpredictably.

The layout it enforces: neo-tree left (34 columns), quickfix / trouble / tasks / help /
terminal / dap-repl bottom, grug-far right. `<leader>ue` toggles the docking.

Deliberately conservative: `animate = false`, because snacks.scroll already animates and
two animation systems on the same window looks wrong. neo-tree is pinned left specifically
so auto-session's close/restore hooks keep working across a save/restore cycle.

To change the layout, edit the `bottom` / `left` / `right` lists — each entry matches a
filetype.

### nvzone: volt, minty, menu — `ui/nvzone.lua`

Three small NvChad widgets. `volt` is the shared rendering library the other two need.

- **minty** — `<leader>uc` opens a color picker (Huefy), `<leader>uC` shows shades of a
  color. Useful when writing CSS or tweaking a theme and you want to *see* the color.
- **menu** — right-click opens a context menu, with a neo-tree-specific menu when you
  right-click in the tree.

### smear-cursor.nvim — `ui/smear-cursor.lua`

Cosmetic: animates a trail behind the cursor when it jumps, which makes it easier to track
where it went after a large motion. Disabled on the dashboard, which repaints constantly.

Purely visual — delete the file if you find it distracting.

### vim-startuptime — `ui/startuptime.lua`

`<leader>us` runs Neovim ten times and shows a breakdown of what each plugin and file cost
at startup, sorted by time.

Note the distinction from the other profilers here: this measures **startup**. `:Lazy
profile` also measures startup but only for plugins, `Snacks.profiler` measures a running
session, and `perf` / `valgrind` (see `CLAUDE.md`) profile *your code*, not the editor.

---

## Not covered here

Pure dependencies pulled in automatically — plenary, nui, nvim-nio, FixCursorHold,
nvim-web-devicons, blink.compat, and the mason glue plugins — have no user-facing surface
and no configuration worth documenting.

For the rest of the stack see the README's plugin table and keymap sections, and the **Key
Architectural Notes** in `CLAUDE.md` for the decisions behind the LSP, completion and
treesitter setup.
