#!/usr/bin/env bash

set -e

echo "Rose Pine Hyprland Dotfiles Uninstall Script"
echo "--------------------------------------------"

# Remove config directories and files
CONFIGS=(
  "kitty"
  "hypr"
  "waybar"
  "rofi"
  "starship"
  "nvim"
  "swaync"
  "qt6ct"
  "gtk-3.0"
  "zsh/.zshrc"
)

for cfg in "${CONFIGS[@]}"; do
  TARGET="$HOME/.config/$cfg"
  if [ -L "$TARGET" ] || [ -d "$TARGET" ] || [ -f "$TARGET" ]; then
    echo "Removing $TARGET"
    rm -rf "$TARGET"
  fi
done

# Remove wallpapers
if [ -d "$HOME/.config/wallpapers" ]; then
  echo "Removing $HOME/.config/wallpapers"
  rm -rf "$HOME/.config/wallpapers"
fi

# Optionally remove .zshrc in home if it was symlinked
if [ -L "$HOME/.zshrc" ]; then
  echo "Removing $HOME/.zshrc"
  rm -f "$HOME/.zshrc"
fi

# Remove SDDM theme config if it points to rose-pine
if [ -f /etc/sddm.conf.d/10-theme.conf ]; then
  if grep -q "rose-pine" /etc/sddm.conf.d/10-theme.conf; then
    echo "Removing SDDM rose-pine theme config"
    sudo rm -f /etc/sddm.conf.d/10-theme.conf
  fi
fi

echo
read -p "Do you want to uninstall all packages installed by this dotfiles setup? (y/N): " REMOVE_PKGS
if [[ "$REMOVE_PKGS" =~ ^[Yy]$ ]]; then
  # Detect distro
  if [ -f /etc/arch-release ]; then
    PKGLIST="$(dirname "$0")/../packages/arch.txt"
    PKGMGR="yay"
    if ! command -v yay >/dev/null 2>&1; then
      PKGMGR="pacman"
    fi
    echo "Uninstalling packages listed in $PKGLIST ..."
    grep -vE '^\s*#' "$PKGLIST" | xargs -r $PKGMGR -Rns --noconfirm
  elif [ -f /etc/fedora-release ]; then
    PKGLIST="$(dirname "$0")/../packages/fedora.txt"
    echo "Uninstalling packages listed in $PKGLIST ..."
    grep -vE '^\s*#' "$PKGLIST" | xargs -r sudo dnf remove -y
  else
    echo "Automatic package removal is not supported for this distro."
  fi
else
  echo "Skipping package removal."
fi

echo "Uninstallation complete."
