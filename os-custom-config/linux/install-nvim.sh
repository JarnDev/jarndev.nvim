#!/usr/bin/env bash
# Full setup for the jarndev.nvim Neovim profile.
#
# Supports Debian/Ubuntu (apt) and Arch/Omarchy (pacman). Everything is *detected*
# rather than assumed -- package manager, session type, terminal, existing Neovim --
# so it degrades sanely on a distro or desktop it has not seen before.
#
# Idempotent: every step checks the target state first and skips if already met, so
# re-running is safe and sudo is only invoked for steps that genuinely need it.
#
# Usage:
#   bash install-nvim.sh            # install / update everything
#   bash install-nvim.sh --check    # report state, change nothing
#
# Bootstrap on a machine that has not cloned the repo yet:
#   curl -fsSL https://raw.githubusercontent.com/JarnDev/jarndev.nvim/master/os-custom-config/linux/install-nvim.sh | bash
set -euo pipefail

NVIM_VERSION="${NVIM_VERSION:-v0.12.5}"   # used only when we have to install it ourselves
NVIM_MIN_MINOR=11                          # config needs >= 0.11 (vim.lsp.config, vim.hl)
NODE_MIN_MAJOR=20
REPO_URL="${REPO_URL:-https://github.com/JarnDev/jarndev.nvim.git}"
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/jarndev.nvim}"
APPNAME="jarndev.nvim"
CHECK_ONLY=0
[ "${1:-}" = "--check" ] && CHECK_ONLY=1

log()  { printf '[nvim-setup] %s\n' "$*"; }
warn() { printf '[nvim-setup] !! %s\n' "$*" >&2; }
skip() { printf '[nvim-setup] .. %s (ja ok)\n' "$*"; }
todo=()
run() {
  if [ "$CHECK_ONLY" = 1 ]; then printf '[nvim-setup] would run: %s\n' "$*"; return 0; fi
  "$@"
}
# Steps whose whole effect is a guarded heredoc never pass through run(), so under
# --check they would announce themselves in the affirmative with nothing marking them
# as hypothetical -- output that reads as if the file had already been written. Route
# every appending step through this so it is as unambiguous as a `would run:` line.
log_write() {   # $1 = what is being written, $2 = target file
  if [ "$CHECK_ONLY" = 1 ]; then printf '[nvim-setup] would append: %s -> %s\n' "$1" "$2"
  else log "escrevendo $1 em $2"; fi
}

# ------------------------------------------------------------------- distro/session
DISTRO=unknown
OS_RELEASE="${OS_RELEASE:-/etc/os-release}"   # overridable so the detection can be tested
if [ -r "$OS_RELEASE" ]; then
  # shellcheck source=/dev/null
  . "$OS_RELEASE"
  case " ${ID:-} ${ID_LIKE:-} " in
    *" debian "*|*" ubuntu "*) DISTRO=debian ;;
    *" arch "*)                DISTRO=arch ;;
  esac
  # Omarchy identifies as its own ID with arch in ID_LIKE; the case above catches it,
  # but fall back on the package manager if a distro invents its own identifiers.
fi
[ "$DISTRO" = unknown ] && command -v pacman  >/dev/null && DISTRO=arch
[ "$DISTRO" = unknown ] && command -v apt-get >/dev/null && DISTRO=debian
log "distro detectada: ${PRETTY_NAME:-desconhecida}  ->  familia: $DISTRO"

# Which rc file to write PATH into. SHELL_ENV must be a file read by EVERY invocation
# of the shell, including non-interactive ones -- that is where the LSPs live. Only zsh
# has such a file. SHELL_RC is the interactive rc, used for aliases only.
case "$(basename "${SHELL:-sh}")" in
  zsh)  SHELL_ENV="$HOME/.zshenv"; SHELL_RC="$HOME/.zshrc" ;;
  # bash has no ~/.zshenv equivalent. ~/.bashrc is not read by non-interactive shells,
  # and distro rc files (Omarchy's) `return` for them within the first few lines anyway,
  # so an appended export is dead code exactly where it is needed. Leave SHELL_ENV empty
  # and let the node step hand the user precise instructions instead.
  bash) SHELL_ENV="";              SHELL_RC="$HOME/.bashrc" ;;
  *)    SHELL_ENV="";              SHELL_RC="" ;;   # fish/nu: different export syntax
esac

# Wayland (Omarchy/Hyprland) needs wl-clipboard; X11 needs xclip.
if [ "${XDG_SESSION_TYPE:-}" = wayland ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
  CLIP_PKG_debian=wl-clipboard; CLIP_PKG_arch=wl-clipboard; CLIP_BIN=wl-copy
else
  CLIP_PKG_debian=xclip;        CLIP_PKG_arch=xclip;        CLIP_BIN=xclip
fi

# ----------------------------------------------------------------------- packages
pkg_installed() {
  case "$DISTRO" in
    debian) dpkg -s "$1" >/dev/null 2>&1 ;;
    arch)   pacman -Q "$1" >/dev/null 2>&1 ;;
    *)      return 0 ;;   # unknown distro: never claim something is missing
  esac
}

case "$DISTRO" in
  debian) PKGS=(git make unzip curl gcc g++ gdb ripgrep fd-find python3-venv chafa "$CLIP_PKG_debian") ;;
  arch)   PKGS=(git base-devel unzip curl gdb ripgrep fd python chafa "$CLIP_PKG_arch") ;;
  *)      PKGS=() ;;
esac

if [ ${#PKGS[@]} -eq 0 ]; then
  warn "distro nao reconhecida; instale manualmente: git make unzip curl gcc gdb ripgrep fd $CLIP_BIN"
else
  missing=()
  for p in "${PKGS[@]}"; do pkg_installed "$p" || missing+=("$p"); done
  if [ ${#missing[@]} -eq 0 ]; then
    skip "pacotes do sistema"
  else
    log "instalando: ${missing[*]}"
    case "$DISTRO" in
      debian) run sudo apt-get update -qq && run sudo apt-get install -y "${missing[@]}" ;;
      arch)   run sudo pacman -S --needed --noconfirm "${missing[@]}" ;;
    esac
  fi
fi

# Debian ships fd as fdfind; Arch ships it as fd already.
if command -v fdfind >/dev/null && ! command -v fd >/dev/null; then
  [ "$CHECK_ONLY" = 0 ] && mkdir -p "$HOME/.local/bin"
  run ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  log "symlink fd -> fdfind criado em ~/.local/bin"
fi

# ------------------------------------------------------------------------- neovim
nvim_minor() { "$1" --version 2>/dev/null | head -1 | sed 's/^NVIM v[0-9]*\.\([0-9]*\).*/\1/'; }

sys_nvim="$(command -v nvim || true)"
sys_minor=""
[ -n "$sys_nvim" ] && sys_minor="$(nvim_minor "$sys_nvim")"

if [ -n "$sys_minor" ] && [ "$sys_minor" -ge "$NVIM_MIN_MINOR" ] 2>/dev/null; then
  # Arch/Omarchy ship a current Neovim; installing our own into /opt would create the
  # exact PATH-shadowing duplicate this script warns about on Debian. Leave it alone.
  skip "neovim $("$sys_nvim" --version | head -1 | awk '{print $2}') em $sys_nvim"
elif [ "$DISTRO" = arch ]; then
  log "instalando neovim via pacman"
  run sudo pacman -S --needed --noconfirm neovim
else
  # Debian/Ubuntu ship an old Neovim (and the PPA ships -dev builds), so use the
  # upstream tarball pinned to $NVIM_VERSION.
  pkg_installed neovim && {
    warn "existe um neovim via apt que vai conflitar com o de /opt"
    todo+=("sudo apt remove neovim neovim-runtime   # remove o duplicado do apt")
  }
  log "instalando neovim $NVIM_VERSION em /opt (atual: ${sys_minor:+0.$sys_minor}${sys_minor:-nenhum})"
  tmp=/tmp/nvim-setup-download
  [ "$CHECK_ONLY" = 0 ] && tmp="$(mktemp -d)"
  run curl -fsSL -o "$tmp/nvim.tar.gz" \
    "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux-x86_64.tar.gz"
  run sudo rm -rf /opt/nvim-linux-x86_64
  run sudo tar -C /opt -xzf "$tmp/nvim.tar.gz"
  run sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
  [ "$CHECK_ONLY" = 0 ] && rm -rf "$tmp"
fi

# --------------------------------------------------------------------------- node
# Every Node-based LSP (ts_ls, eslint, jsonls, html, cssls, tailwindcss, bashls,
# yamlls, dockerls) needs a real node binary on PATH. Neovim execs those servers
# directly, inheriting the PATH of whatever launched it.
NODE_MAJOR_OF() { "$1" --version 2>/dev/null | sed 's/^v//; s/\..*//'; }

# The question worth asking is not "which rc file mentions node" but "will Neovim
# actually find node". Answer it empirically, in a *clean login shell*: that is what a
# fresh terminal or a desktop entry gets, and unlike a bare `bash -c` it does not
# inherit whatever this script's own shell happens to have loaded.
node_from_login_shell() {
  local sh out
  sh="$(command -v "$(basename "${SHELL:-sh}")" 2>/dev/null)" || return 1
  [ -x "$sh" ] || return 1
  # timeout: a broken or interactive-assuming rc must not hang the installer.
  out="$(timeout 10 env -i HOME="$HOME" TERM=dumb "$sh" -lc 'command -v node' 2>/dev/null | tail -1)"
  # A version manager's shell *function* prints a bare name, not a path. That is the
  # exact nvm failure this step exists for, so it must not count as success.
  case "$out" in /*) [ -x "$out" ] && printf '%s\n' "$out" ;; esac
}

node_bin=""
login_node="$(node_from_login_shell || true)"
if [ -n "$login_node" ] && [ "$(NODE_MAJOR_OF "$login_node")" -ge "$NODE_MIN_MAJOR" ] 2>/dev/null; then
  # Already reachable -- via a distro default, mise shims exported by the distro's own
  # env bootstrap (Omarchy), or a previous run of this script. Writing a PATH export on
  # top of this would pin a version that a `mise up node` then invalidates.
  node_bin="$(dirname "$login_node")"
  skip "node v$(NODE_MAJOR_OF "$login_node") ja visivel para o Neovim ($node_bin)"
else
  # Not reachable: find one to point at. Prefer version-agnostic shims over any path
  # containing a version number.
  if [ -x "$HOME/.local/share/mise/shims/node" ]; then
    node_bin="$HOME/.local/share/mise/shims"
  elif [ -d "$HOME/.nvm/versions/node" ]; then
    node_bin="$(find "$HOME/.nvm/versions/node" -maxdepth 2 -type d -name bin 2>/dev/null | sort -V | tail -1)"
  elif command -v node >/dev/null; then
    node_bin="$(dirname "$(readlink -f "$(command -v node)")")"
  fi
  if [ -n "$node_bin" ]; then
    have="$(NODE_MAJOR_OF "$node_bin/node")"
    if [ -z "$have" ] || [ "$have" -lt "$NODE_MIN_MAJOR" ] 2>/dev/null; then
      warn "node em $node_bin e v${have:-?}, abaixo do minimo v$NODE_MIN_MAJOR"
      node_bin=""
    fi
  fi

  if [ -z "$node_bin" ]; then
    warn "nenhum node utilizavel encontrado"
    case "$DISTRO" in
      arch) todo+=("sudo pacman -S nodejs npm    # ou 'mise use -g node@lts', depois rode este script de novo") ;;
      *)    todo+=("instale o Node >= $NODE_MIN_MAJOR (nvm install --lts) e rode este script de novo") ;;
    esac
  elif [ -n "$SHELL_ENV" ]; then
    if grep -qs "$node_bin" "$SHELL_ENV" 2>/dev/null; then
      # Present in the file yet the login shell could not resolve it: do not append a
      # duplicate, the problem is elsewhere (ordering, or an rc that overrides PATH).
      warn "$SHELL_ENV ja cita $node_bin mas o login shell nao acha node -- verifique a ordem no arquivo"
    else
      log_write "node no PATH ($node_bin)" "$SHELL_ENV"
      [ "$CHECK_ONLY" = 0 ] && cat >> "$SHELL_ENV" <<EOF

# Gerenciadores de versao (nvm/mise) expoem node/npm como funcoes ou shims que nao
# existem em shells nao-interativos. Sem isto nenhum LSP baseado em Node inicia
# dentro do Neovim, que executa os servidores diretamente.
export PATH="$node_bin:\$PATH"
EOF
    fi
  else
    # bash and friends: there is no file with ~/.zshenv semantics, and appending to
    # ~/.bashrc is worse than useless -- distro rc files (Omarchy's is one) return early
    # for non-interactive shells within the first few lines, so an appended export is
    # dead code precisely for the shells the LSPs run in. Hand this to the user with the
    # trap spelled out rather than writing something that silently does nothing.
    warn "node em $node_bin nao esta visivel para shells nao-interativos"
    todo+=("exporte PATH=\"$node_bin:\$PATH\" num arquivo lido incondicionalmente (~/.profile, ou ACIMA do 'return' de nao-interativo no ~/.bashrc) -- acrescentar no FIM do ~/.bashrc nao funciona")
  fi
fi
# --------------------------------------------------------------------------- repo
if [ -d "$CONFIG_DIR/.git" ]; then
  skip "config em $CONFIG_DIR"
elif [ -e "$CONFIG_DIR" ]; then
  warn "$CONFIG_DIR existe e nao e um repo git; nao vou mexer"
  todo+=("mova ou remova $CONFIG_DIR e rode este script de novo")
else
  log "clonando config em $CONFIG_DIR"
  run git clone "$REPO_URL" "$CONFIG_DIR"
fi

# ------------------------------------------------------------------------ terminal
# smart-splits can only cross pane boundaries on kitty, wezterm, tmux and zellij.
# Omarchy's default terminal is neither, so there the <C-hjkl> keys stay Neovim-only.
KITTY_CONF="$HOME/.config/kitty/kitty.conf"
# Test for the binary, not the file: Omarchy ships themed configs for kitty, ghostty,
# alacritty and foot regardless of which is installed, so a kitty.conf proves nothing.
# Appending `allow_remote_control yes` to a config for an absent terminal would also be
# a security-relevant change made for no reason.
if command -v kitty >/dev/null && [ -f "$KITTY_CONF" ]; then
  if grep -q "IS_NVIM" "$KITTY_CONF"; then
    skip "mapeamentos smart-splits no kitty.conf"
  else
    log_write "mapeamentos smart-splits do kitty" "$KITTY_CONF"
    [ "$CHECK_ONLY" = 0 ] && cat >> "$KITTY_CONF" <<'EOF'

# --- smart-splits.nvim: <C-hjkl> navega entre panes do kitty E splits do Neovim ---
map ctrl+h neighboring_window left
map ctrl+j neighboring_window down
map ctrl+k neighboring_window up
map ctrl+l neighboring_window right

map --when-focus-on var:IS_NVIM ctrl+h
map --when-focus-on var:IS_NVIM ctrl+j
map --when-focus-on var:IS_NVIM ctrl+k
map --when-focus-on var:IS_NVIM ctrl+l

map alt+h kitten relative_resize.py left  3
map alt+j kitten relative_resize.py down  3
map alt+k kitten relative_resize.py up    3
map alt+l kitten relative_resize.py right 3

map --when-focus-on var:IS_NVIM alt+h
map --when-focus-on var:IS_NVIM alt+j
map --when-focus-on var:IS_NVIM alt+k
map --when-focus-on var:IS_NVIM alt+l

allow_remote_control yes
listen_on unix:@mykitty
EOF
    todo+=("reinicie o kitty por completo (allow_remote_control/listen_on so valem em instancias novas)")
  fi
fi

# tmux is the portable fallback -- it also needs bindings on its own side, and it is
# what Omarchy offers (Super+Alt+Return), since Ghostty/Alacritty/Foot have no
# multiplexer integration in smart-splits.
if command -v tmux >/dev/null; then
  TMUX_CONF="$HOME/.config/tmux/tmux.conf"
  [ -f "$HOME/.tmux.conf" ] && TMUX_CONF="$HOME/.tmux.conf"
  if [ -f "$TMUX_CONF" ] && grep -q "pane-is-vim" "$TMUX_CONF"; then
    skip "bindings smart-splits no $(basename "$TMUX_CONF")"
  else
    log_write "bindings smart-splits do tmux" "$TMUX_CONF"
    if [ "$CHECK_ONLY" = 0 ]; then
      mkdir -p "$(dirname "$TMUX_CONF")"
      cat >> "$TMUX_CONF" <<'EOF'

# --- smart-splits.nvim: <C-hjkl> navega entre panes do tmux E splits do Neovim ---
# '@pane-is-vim' e setado pelo plugin ao carregar (por isso ele nao e lazy-loaded).
bind-key -n C-h if -F "#{@pane-is-vim}" 'send-keys C-h' 'select-pane -L'
bind-key -n C-j if -F "#{@pane-is-vim}" 'send-keys C-j' 'select-pane -D'
bind-key -n C-k if -F "#{@pane-is-vim}" 'send-keys C-k' 'select-pane -U'
bind-key -n C-l if -F "#{@pane-is-vim}" 'send-keys C-l' 'select-pane -R'

bind-key -n M-h if -F "#{@pane-is-vim}" 'send-keys M-h' 'resize-pane -L 3'
bind-key -n M-j if -F "#{@pane-is-vim}" 'send-keys M-j' 'resize-pane -D 3'
bind-key -n M-k if -F "#{@pane-is-vim}" 'send-keys M-k' 'resize-pane -U 3'
bind-key -n M-l if -F "#{@pane-is-vim}" 'send-keys M-l' 'resize-pane -R 3'

bind-key -T copy-mode-vi 'C-h' select-pane -L
bind-key -T copy-mode-vi 'C-j' select-pane -D
bind-key -T copy-mode-vi 'C-k' select-pane -U
bind-key -T copy-mode-vi 'C-l' select-pane -R
EOF
    fi
    todo+=("recarregue o tmux:  tmux source-file $TMUX_CONF")
  fi
elif ! command -v kitty >/dev/null; then
  log "sem kitty nem tmux -- <C-hjkl> navega apenas entre splits do Neovim"
  log "  (smart-splits so cruza panes em kitty, wezterm, tmux e zellij)"
fi

# Some distros (Omarchy) generate and version the terminal/tmux configs themselves, so
# anything appended here can be overwritten by a system update.
if [ "${ID:-}" = omarchy ]; then
  todo+=("os configs de terminal/tmux sao gerenciados pelo Omarchy -- se um update sobrescrever, rode este script de novo")
fi

# ----------------------------------------------------------------- plugins + mason
if [ "$CHECK_ONLY" = 1 ]; then
  log "would run: lazy sync + mason install (headless)"
else
  log "instalando plugins (lazy) -- pode demorar alguns minutos"
  [ -n "$node_bin" ] && export PATH="$node_bin:$PATH"
  NVIM_APPNAME="$APPNAME" nvim --headless "+Lazy! sync" +qa 2>&1 | tail -3 || true
  log "instalando servidores LSP e ferramentas (mason)"
  NVIM_APPNAME="$APPNAME" nvim --headless \
    -c 'lua require("mason-lspconfig.features.ensure_installed")()' \
    -c 'lua vim.wait(600000, function()
          for _, p in ipairs(require("mason-registry").get_all_packages()) do
            if p:is_installing() then return false end
          end
          return true
        end, 2000)' -c qa 2>&1 | tail -3 || true
fi

# --------------------------------------------------------------------------- shell
if [ -n "$SHELL_RC" ] && grep -qs "NVIM_APPNAME" "$SHELL_RC" 2>/dev/null; then
  skip "NVIM_APPNAME em $(basename "$SHELL_RC")"
elif [ -d "$HOME/.config/nvim" ]; then
  # Omarchy ships its own Neovim config (LazyVim) at ~/.config/nvim, and its `n` alias
  # plus the Setup > Configs menu both target it. A global export would hijack all of
  # that, so alias this profile instead of making it the default.
  log "ja existe outra config em ~/.config/nvim -- nao torne esta a padrao globalmente"
  todo+=("alias jn='NVIM_APPNAME=$APPNAME nvim'   # ${SHELL_RC:-rc do shell}: mantem a config existente intacta")
else
  todo+=("export NVIM_APPNAME=\"$APPNAME\"   # adicione ao ${SHELL_RC:-rc do shell} para 'nvim' usar este perfil")
fi

command -v gh >/dev/null && gh auth status >/dev/null 2>&1 \
  && skip "gh autenticado" \
  || todo+=("gh auth login    # necessario para o octo.nvim (PRs/issues)")

command -v "$CLIP_BIN" >/dev/null || todo+=("instale $CLIP_BIN para o clipboard do sistema")

# Optional: used by one feature each, so they are reported rather than installed.
PKG_INSTALL="sudo apt-get install -y"; [ "$DISTRO" = arch ] && PKG_INSTALL="sudo pacman -S"
command -v cmake >/dev/null || todo+=("$PKG_INSTALL cmake    # projetos C/C++ com compile_commands.json (clangd)")
command -v mpv   >/dev/null || todo+=("$PKG_INSTALL mpv      # reproducao de video (<leader>rv)")

# ----------------------------------------------------------------------------- fim
echo
log "resumo:"
printf '  distro    : %s (%s)\n' "${PRETTY_NAME:-?}" "$DISTRO"
printf '  nvim      : %s\n' "$(nvim --version 2>/dev/null | head -1 || echo 'nao encontrado')"
printf '  config    : %s\n' "$CONFIG_DIR"
printf '  node      : %s\n' "${node_bin:-NAO ENCONTRADO}${node_bin:+ (v$(NODE_MAJOR_OF "$node_bin/node"))}"
printf '  clipboard : %s\n' "$(command -v "$CLIP_BIN" >/dev/null && echo "$CLIP_BIN" || echo "$CLIP_BIN FALTANDO")"
if [ ${#todo[@]} -gt 0 ]; then
  echo; log "passos manuais restantes:"
  for t in "${todo[@]}"; do printf '  - %s\n' "$t"; done
fi
echo
log "verifique com:  NVIM_APPNAME=$APPNAME nvim -c 'checkhealth vim.lsp'"
