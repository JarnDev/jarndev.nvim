# Setup — Ubuntu / Debian

## 1. Install Neovim

The PPA provides the latest stable build:

```sh
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install neovim
```

Or install from the official release tarball:

```sh
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
```

## 2. Install Core Dependencies

```sh
sudo apt install -y git make gcc ripgrep unzip xclip curl
```

## 3. Install lazygit

```sh
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
  | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
curl -Lo lazygit.tar.gz \
  "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit lazygit.tar.gz
```

## 4. Install lazydocker

```sh
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
```

## 5. Install a Nerd Font (optional)

Download a font from [nerdfonts.com](https://www.nerdfonts.com/font-downloads), extract it to `~/.local/share/fonts/`, then run `fc-cache -fv`. Set `vim.g.have_nerd_font = true` in `init.lua`.

## 6. Clone the Config

```sh
git clone https://github.com/Alfredo/jarndev.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
```

## 7. Set the Anthropic API Key

Add to your shell profile (`~/.bashrc` or `~/.zshrc`):

```sh
export ANTHROPIC_API_KEY="sk-ant-..."
```

## 8. Install Claude Code CLI (optional)

```sh
npm install -g @anthropic-ai/claude-code
```

Requires Node.js >= 18.

## 9. Launch

```sh
nvim
```

Lazy.nvim installs all plugins on first launch. Run `:Lazy` to check status, `:Mason` to manage LSP servers.
