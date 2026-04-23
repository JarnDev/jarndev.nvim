# Setup — macOS

## 1. Install Homebrew (if not installed)

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 2. Install Neovim and Core Dependencies

```sh
brew install neovim git make gcc ripgrep unzip lazygit lazydocker
```

## 3. Install a Nerd Font (optional)

```sh
brew install --cask font-jetbrains-mono-nerd-font
```

Then set `vim.g.have_nerd_font = true` in `init.lua`.

## 4. Clone the Config

```sh
git clone https://github.com/Alfredo/jarndev.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
```

## 5. Set the Anthropic API Key

Add to your shell profile (`~/.zshrc`):

```sh
export ANTHROPIC_API_KEY="sk-ant-..."
```

## 6. Install Claude Code CLI (optional)

```sh
npm install -g @anthropic-ai/claude-code
```

Requires Node.js >= 18. Install via `brew install node` if needed.

## 7. Launch

```sh
nvim
```

Lazy.nvim installs all plugins on first launch. Run `:Lazy` to check status, `:Mason` to manage LSP servers.
