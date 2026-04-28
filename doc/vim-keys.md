# Vim Special Keys Reference

## Navigation `[` / `]`
| Key | Action |
|-----|--------|
| `]d` / `[d` | Next / prev diagnostic |
| `]c` / `[c` | Next / prev git hunk |
| `]x` / `[x` | Next / prev Trouble item |
| `]q` / `[q` | Next / prev quickfix item |
| `]l` / `[l` | Next / prev location list |
| `]t` / `[t` | Next / prev tag |
| `]m` / `[m` | Next / prev method start |
| `]M` / `[M` | Next / prev method end |
| `]]` / `[[` | Next / prev section |
| `](` / `[(` | Next / prev unmatched `(` |
| `]{` / `[{` | Next / prev unmatched `{` |

## Goto `g`
| Key | Action |
|-----|--------|
| `gd` | LSP Definition |
| `gr` | LSP References |
| `gI` | LSP Implementation |
| `gD` | LSP Declaration |
| `gK` | Hover provider picker |
| `gf` | Open file under cursor |
| `gi` | Go to last insert position |
| `gv` | Re-select last visual selection |
| `gg` / `G` | First / last line |
| `g;` / `g,` | Prev / next change position |
| `gJ` | Join lines without space |
| `gq` | Format / wrap text |

## Fold & View `z`
| Key | Action |
|-----|--------|
| `za` | Toggle fold |
| `zo` / `zc` | Open / close fold |
| `zO` / `zC` | Open / close all folds recursively |
| `zR` / `zM` | Open all / close all folds |
| `zf` | Create fold (visual) |
| `zd` | Delete fold |
| `zz` | Centre cursor on screen |
| `zt` / `zb` | Cursor to top / bottom of screen |
| `zh` / `zl` | Scroll left / right |

## Operators `c` `d` `y`
| Key | Action |
|-----|--------|
| `ciw` / `diw` / `yiw` | Change / delete / yank inner word |
| `caw` / `daw` / `yaw` | Change / delete / yank around word |
| `ci"` / `di"` / `yi"` | Change / delete / yank inside `"` |
| `ca"` / `da"` / `ya"` | Change / delete / yank around `"` |
| `ci(` / `di(` / `yi(` | Change / delete / yank inside `()` |
| `ci{` / `di{` / `yi{` | Change / delete / yank inside `{}` |
| `cc` / `dd` / `yy` | Change / delete / yank whole line |
| `C` / `D` | Change / delete to end of line |
| `cw` / `dw` | Change / delete word forward |

## Marks `m` `'` `` ` ``
| Key | Action |
|-----|--------|
| `ma`–`mz` | Set local mark a–z |
| `mA`–`mZ` | Set global mark A–Z |
| `'a` | Jump to line of mark a |
| `` `a `` | Jump to exact position of mark a |
| `''` | Jump back to last jump position (line) |
| ` `` ` | Jump back to last jump position (exact) |

## Registers `"` `@`
| Key | Action |
|-----|--------|
| `"ay` | Yank into register a |
| `"ap` | Paste from register a |
| `"+y` / `"+p` | Yank / paste system clipboard |
| `"0p` | Paste last yank (not delete) |
| `qa` | Record macro into register a |
| `q` | Stop recording |
| `@a` | Play macro from register a |
| `@@` | Repeat last macro |
| `:reg` | Show all registers |

## Find in Line `f` `F` `t` `T`
| Key | Action |
|-----|--------|
| `fx` | Jump to next `x` on line |
| `Fx` | Jump to prev `x` on line |
| `tx` | Jump just before next `x` |
| `Tx` | Jump just before prev `x` |
| `;` / `,` | Repeat f/F/t/T forward / backward |

## Replace `r` `R`
| Key | Action |
|-----|--------|
| `rx` | Replace char under cursor with `x` |
| `R` | Enter replace mode |
| `~` | Toggle case of char |
| `g~iw` | Toggle case of word |
| `guiw` / `gUiw` | Lowercase / uppercase word |
