#!/usr/bin/env bash
# Full setup for the jarndev.nvim Neovim profile on a fresh Debian/Ubuntu machine.
#
# Idempotent: every step checks the target state first and skips if already met, so
# re-running it is safe and touches nothing it does not have to. sudo is only invoked
# for steps that genuinely need it (apt packages, /opt), and only when they are missing.
#
# Usage:
#   bash install-nvim.sh            # install / update everything
#   bash install-nvim.sh --check    # report state, change nothing
#
# Bootstrap on a machine that has not cloned the repo yet:
#   curl -fsSL https://raw.githubusercontent.com/JarnDev/jarndev.nvim/master/os-custom-config/linux/install-nvim.sh | bash
set -euo pipefail

NVIM_VERSION="${NVIM_VERSION:-v0.12.5}"
REPO_URL="${REPO_URL:-https://github.com/JarnDev/jarndev.nvim.git}"
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/jarndev.nvim}"
APPNAME="jarndev.nvim"
CHECK_ONLY=0
[ "${1:-}" = "--check" ] && CHECK_ONLY=1

log()  { printf '[nvim-setup] %s\n' "$*"; }
warn() { printf '[nvim-setup] !! %s\n' "$*" >&2; }
skip() { printf '[nvim-setup] .. %s (ja ok)\n' "$*"; }
todo=()

run() { # run, or just report under --check
  if [ "$CHECK_ONLY" = 1 ]; then printf '[nvim-setup] would run: %s\n' "$*"; return 0; fi
  "$@"
}

# --------------------------------------------------------------------------- apt
APT_PKGS=(git make unzip curl gcc g++ gdb ripgrep fd-find xclip python3-venv)
missing=()
for p in "${APT_PKGS[@]}"; do
  dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p")
done
if [ ${#missing[@]} -eq 0 ]; then
  skip "pacotes apt"
else
  log "instalando pacotes apt: ${missing[*]}"
  run sudo apt-get update -qq
  run sudo apt-get install -y "${missing[@]}"
fi

# Ubuntu ships fd as fdfind; snacks finds either, but `fd` is the conventional name.
if command -v fdfind >/dev/null && ! command -v fd >/dev/null; then
  mkdir -p "$HOME/.local/bin"
  run ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  log "criado symlink fd -> fdfind em ~/.local/bin"
fi

# ------------------------------------------------------------------------- neovim
# The distro package is a trap: Ubuntu's neovim is old (and the PPA ships -dev builds),
# and having both shadows whichever comes first on PATH.
if dpkg -s neovim >/dev/null 2>&1; then
  warn "existe um neovim instalado via apt que vai conflitar com o de /opt."
  todo+=("sudo apt remove neovim neovim-runtime   # remove o duplicado do apt")
fi

current="$(/opt/nvim-linux-x86_64/bin/nvim --version 2>/dev/null | head -1 | awk '{print $2}' || true)"
if [ "$current" = "$NVIM_VERSION" ]; then
  skip "neovim $NVIM_VERSION"
else
  log "instalando neovim $NVIM_VERSION (atual: ${current:-nenhum})"
  tarball="nvim-linux-x86_64.tar.gz"
  tmp="$(mktemp -d)"
  run curl -fsSL -o "$tmp/$tarball" \
    "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/$tarball"
  run sudo rm -rf /opt/nvim-linux-x86_64
  run sudo tar -C /opt -xzf "$tmp/$tarball"
  run sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
  rm -rf "$tmp"
fi

# --------------------------------------------------------------------------- node
# Every Node-based LSP (ts_ls, eslint, jsonls, html, cssls, tailwindcss, bashls,
# yamlls, dockerls) needs a real node binary on PATH. If node/npm are lazy nvm shell
# functions they do not exist for Neovim, which spawns servers directly.
# Prefer the newest nvm install over a distro node: Ubuntu ships Node 18, which is
# too old for several Mason tools (markdownlint-cli2 crashes on it).
NODE_MIN_MAJOR=20
node_major() { "$1/node" --version 2>/dev/null | sed 's/^v//; s/\..*//'; }

node_bin=""
if [ -d "$HOME/.nvm/versions/node" ]; then
  node_bin="$(find "$HOME/.nvm/versions/node" -maxdepth 2 -type d -name bin 2>/dev/null | sort -V | tail -1)"
fi
if [ -z "$node_bin" ] && command -v node >/dev/null; then
  node_bin="$(dirname "$(readlink -f "$(command -v node)")")"
fi
if [ -n "$node_bin" ]; then
  have="$(node_major "$node_bin")"
  if [ -z "$have" ] || [ "$have" -lt "$NODE_MIN_MAJOR" ]; then
    warn "node encontrado em $node_bin e v${have:-?}, abaixo do minimo v$NODE_MIN_MAJOR"
    node_bin=""
  fi
fi

if [ -z "$node_bin" ]; then
  warn "nenhum node utilizavel encontrado."
  todo+=("instale o Node >= $NODE_MIN_MAJOR (nvm: https://github.com/nvm-sh/nvm) e rode este script de novo")
elif grep -qs 'versions/node' "$HOME/.zshenv" 2>/dev/null; then
  skip "node no PATH via ~/.zshenv"
else
  log "adicionando node ao PATH em ~/.zshenv ($node_bin)"
  if [ "$CHECK_ONLY" = 0 ]; then
    cat >> "$HOME/.zshenv" <<EOF

# nvm define node/npm como funcoes lazy no .zshrc, que nao existem em shells
# nao-interativos. Sem isto nenhum LSP baseado em Node inicia dentro do Neovim.
export PATH="$node_bin:\$PATH"
EOF
  fi
fi

# --------------------------------------------------------------------------- repo
if [ -d "$CONFIG_DIR/.git" ]; then
  skip "config em $CONFIG_DIR"
elif [ -e "$CONFIG_DIR" ]; then
  warn "$CONFIG_DIR existe mas nao e um repo git; nao vou mexer."
  todo+=("mova ou remova $CONFIG_DIR e rode este script de novo")
else
  log "clonando config em $CONFIG_DIR"
  run git clone "$REPO_URL" "$CONFIG_DIR"
fi

# --------------------------------------------------------------------------- kitty
KITTY_CONF="$HOME/.config/kitty/kitty.conf"
if [ ! -f "$KITTY_CONF" ]; then
  log "kitty.conf nao existe; pulando integracao smart-splits"
elif grep -q "IS_NVIM" "$KITTY_CONF"; then
  skip "mapeamentos smart-splits no kitty.conf"
else
  log "adicionando mapeamentos smart-splits ao kitty.conf"
  if [ "$CHECK_ONLY" = 0 ]; then
    cat >> "$KITTY_CONF" <<'EOF'

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
  fi
  todo+=("reinicie o kitty por completo (allow_remote_control/listen_on so valem em instancias novas)")
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
          local r = require("mason-registry")
          for _, p in ipairs(r.get_all_packages()) do
            if p:is_installing() then return false end
          end
          return not require("mason-registry.installer").is_installing()
        end, 2000)' -c qa 2>&1 | tail -3 || true
fi

# --------------------------------------------------------------------------- shell
if grep -qs "NVIM_APPNAME" "$HOME/.zshrc" 2>/dev/null; then
  skip "NVIM_APPNAME no .zshrc"
else
  todo+=("export NVIM_APPNAME=\"$APPNAME\"   # adicione ao ~/.zshrc para 'nvim' usar este perfil")
fi

command -v gh >/dev/null && gh auth status >/dev/null 2>&1 \
  && skip "gh autenticado" \
  || todo+=("gh auth login    # necessario para o octo.nvim (PRs/issues)")

# --------------------------------------------------------------------------- fim
echo
log "resumo:"
printf '  nvim      : %s\n' "$(nvim --version 2>/dev/null | head -1 || echo 'nao encontrado')"
printf '  config    : %s\n' "$CONFIG_DIR"
printf '  node      : %s\n' "${node_bin:-NAO ENCONTRADO}${node_bin:+ (v$(node_major "$node_bin"))}"
if [ ${#todo[@]} -gt 0 ]; then
  echo
  log "passos manuais restantes:"
  for t in "${todo[@]}"; do printf '  - %s\n' "$t"; done
fi
echo
log "verifique com:  NVIM_APPNAME=$APPNAME nvim -c 'checkhealth vim.lsp'"
