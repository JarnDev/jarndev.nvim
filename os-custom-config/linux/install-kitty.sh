#!/usr/bin/env bash
# Install/update kitty from the official upstream installer (no sudo).
#
# Do NOT use the Ubuntu apt package: 24.04 LTS ships kitty 0.32.2, which sends the
# key *release* of Enter/Tab/Backspace with the same bytes as the press under the
# Kitty Keyboard Protocol -> every Backspace/Enter is doubled in herdr, Neovim, etc.
# Fixed upstream in kitty 0.33.0 (https://herdr.dev/docs/troubleshooting/).
#
# Usage: bash install-kitty.sh
set -euo pipefail

APP="$HOME/.local/kitty.app"
BIN="$HOME/.local/bin"
APPS="$HOME/.local/share/applications"

echo "[kitty] Installing/updating to $APP ..."
curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n

mkdir -p "$BIN" "$APPS"
ln -sf "$APP/bin/kitty" "$APP/bin/kitten" "$BIN/"

# Desktop entries (override the system ones) pointing at the upstream binary/icon
cp "$APP/share/applications/kitty.desktop" "$APPS/"
[ -f "$APP/share/applications/kitty-open.desktop" ] && cp "$APP/share/applications/kitty-open.desktop" "$APPS/"
sed -i "s|Icon=kitty|Icon=$APP/share/icons/hicolor/256x256/apps/kitty.png|g; s|Exec=kitty|Exec=$APP/bin/kitty|g" "$APPS"/kitty*.desktop
update-desktop-database "$APPS" 2>/dev/null || true

# GNOME: Ctrl+Alt+T and "open terminal" actions
if command -v gsettings >/dev/null; then
  gsettings set org.gnome.desktop.default-applications.terminal exec "$APP/bin/kitty" || true
  gsettings set org.gnome.desktop.default-applications.terminal exec-arg '' || true
fi

echo "[kitty] $("$APP/bin/kitty" --version)"
echo "[kitty] System-wide default (needs sudo):"
echo "  sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator $APP/bin/kitty 60"
echo "  sudo update-alternatives --set x-terminal-emulator $APP/bin/kitty"
