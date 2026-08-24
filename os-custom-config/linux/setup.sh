#!/usr/bin/env bash
# Bootstrap script for a new machine.
# Installs chezmoi and applies your private dotfiles repo.
#
# Usage:
#   DOTFILES_REPO=git@github.com:you/dotfiles.git bash setup.sh
set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/JarnDev/dotfiles.git}"

# Install chezmoi to ~/.local/bin (no sudo needed)
if ! command -v chezmoi &>/dev/null && [ ! -f "$HOME/.local/bin/chezmoi" ]; then
  echo "[setup] Installing chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi

export PATH="$HOME/.local/bin:$PATH"

# Init chezmoi from private dotfiles repo and apply everything
# This will also run the run_once_ install scripts inside the dotfiles repo
chezmoi init --apply "$DOTFILES_REPO"

echo "[setup] Done. Open a new shell to apply changes."
