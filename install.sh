#!/usr/bin/env bash

set -e

# Script version
SCRIPT_VERSION="1.0.0"
GITHUB_REPO="devsimsek/hyprland-dotfiles"

check_latest_version() {
    if command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
        LATEST_VERSION=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | jq -r .tag_name)
        if [ -n "$LATEST_VERSION" ] && [ "$SCRIPT_VERSION" != "$LATEST_VERSION" ]; then
            echo "A new version of this script is available: $LATEST_VERSION (you have $SCRIPT_VERSION)"
            echo "Please update by pulling the latest changes from GitHub."
        fi
    fi
}

check_latest_version

# Detect distro
detect_distro() {
    if [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/fedora-release ]; then
        echo "fedora"
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            nixos) echo "nix" ;;
            arch) echo "arch" ;;
            fedora) echo "fedora" ;;
            *) echo "unsupported" ;;
        esac
    else
        echo "unsupported"
    fi
}

install_arch() {
    echo "Detected Arch Linux."
    sudo pacman -Syu --noconfirm

    # Install base-devel and git if not present
    sudo pacman -S --needed --noconfirm base-devel git

    # Install yay if not present
    if ! command -v yay >/dev/null 2>&1; then
        echo "Installing yay (AUR helper)..."
        YAYDIR="$HOME/yay"
        git clone https://aur.archlinux.org/yay.git "$YAYDIR" || true
        cd "$YAYDIR"
        makepkg -si --noconfirm
        cd ..
        rm -rf "$YAYDIR"
    else
        echo "yay is already installed. (good)"
    fi

    # Install packages from package list
    PKGLIST="$(dirname "$0")/packages/arch.txt"
    if [ ! -f "$PKGLIST" ]; then
        echo "ERROR: Package list $PKGLIST not found!"
        exit 1
    fi
    echo "Installing packages from $PKGLIST..."
    while read -r pkg; do
        [ -z "$pkg" ] && continue
        if yay -Qi "$pkg" &>/dev/null; then
            echo "$pkg" is already installed.
        else
            yay -S --noconfirm "$pkg"
        fi
    done < <(grep -vE '^\s*#' "$PKGLIST")

    # Enable and start SDDM
    echo "Enabling and starting SDDM display manager..."
    sudo systemctl enable sddm
    sudo systemctl start sddm

    # Set SDDM theme to rose-pine
    echo "Setting SDDM theme to rose-pine..."
    if [ -d /etc/sddm.conf.d ]; then
        echo -e "[Theme]\nCurrent=rose-pine" | sudo tee /etc/sddm.conf.d/10-theme.conf
    else
        sudo mkdir -p /etc/sddm.conf.d
        echo -e "[Theme]\nCurrent=rose-pine" | sudo tee /etc/sddm.conf.d/10-theme.conf
    fi

    # Set SDDM theme to rose-pine
    echo "Setting SDDM theme to rose-pine..."
    if [ -d /etc/sddm.conf.d ]; then
        echo -e "[Theme]\nCurrent=rose-pine" | sudo tee /etc/sddm.conf.d/10-theme.conf
    else
        sudo mkdir -p /etc/sddm.conf.d
        echo -e "[Theme]\nCurrent=rose-pine" | sudo tee /etc/sddm.conf.d/10-theme.conf
    fi

   # Symlink configs
   echo "Symlinking configs to ~/.config/ ..."
   mkdir -p "$HOME/.config"
   ln -sf "$(dirname "$0")/config/kitty" "$HOME/.config/kitty"
   ln -sf "$(dirname "$0")/config/hypr" "$HOME/.config/hypr"
   ln -sf "$(dirname "$0")/config/waybar" "$HOME/.config/waybar"
   ln -sf "$(dirname "$0")/config/rofi" "$HOME/.config/rofi"
   ln -sf "$(dirname "$0")/config/starship" "$HOME/.config/starship"
   ln -sf "$(dirname "$0")/config/nvim" "$HOME/.config/nvim"
   ln -sf "$(dirname "$0")/config/swaync" "$HOME/.config/swaync"
   ln -sf "$(dirname "$0")/config/qt6ct" "$HOME/.config/qt6ct"
   ln -sf "$(dirname "$0")/config/gtk-3.0" "$HOME/.config/gtk-3.0"
   ln -sf "$(dirname "$0")/config/zsh/.zshrc" "$HOME/.zshrc"
   mkdir -p "$HOME/.config/wallpapers"
   cp -r "$(dirname "$0")/wallpapers/." "$HOME/.config/wallpapers/"

   # Set zsh as default shell if not already set
   if [ "$SHELL" != "$(which zsh)" ]; then
       echo "Setting zsh as your default shell..."
       chsh -s "$(which zsh)"
   fi

   echo "Arch Linux setup complete."
}

install_fedora() {
    echo "Detected Fedora."
    sudo dnf upgrade -y

    # Enable Copr repo for starship if not already enabled
    if ! rpm -q starship &>/dev/null; then
        sudo dnf install -y 'dnf-command(copr)'
        sudo dnf copr enable atim/starship -y
    fi

    sudo dnf upgrade -y

    # Enable Copr repo for starship if not already enabled
    if ! rpm -q starship &>/dev/null; then
        sudo dnf install -y 'dnf-command(copr)'
        sudo dnf copr enable atim/starship -y
    fi

    while read -r pkg; do
        [ -z "$pkg" ] && continue
        if rpm -q "$pkg" &>/dev/null; then
            echo "$pkg is already installed."
        else
            sudo dnf install -y "$pkg"
        fi
    done < <(grep -vE '^\s*#' "$(dirname "$0")/packages/fedora.txt")
    # Enable and start SDDM
    echo "Enabling and starting SDDM display manager..."
    sudo systemctl enable sddm
    sudo systemctl start sddm

   # Symlink configs
   echo "Symlinking configs to ~/.config/ ..."
   mkdir -p "$HOME/.config"
   ln -sf "$(dirname "$0")/config/kitty" "$HOME/.config/kitty"
   ln -sf "$(dirname "$0")/config/hypr" "$HOME/.config/hypr"
   ln -sf "$(dirname "$0")/config/waybar" "$HOME/.config/waybar"
   ln -sf "$(dirname "$0")/config/rofi" "$HOME/.config/rofi"
   ln -sf "$(dirname "$0")/config/starship" "$HOME/.config/starship"
   ln -sf "$(dirname "$0")/config/nvim" "$HOME/.config/nvim"
   ln -sf "$(dirname "$0")/config/swaync" "$HOME/.config/swaync"
   ln -sf "$(dirname "$0")/config/qt6ct" "$HOME/.config/qt6ct"
   ln -sf "$(dirname "$0")/config/gtk-3.0" "$HOME/.config/gtk-3.0"
   ln -sf "$(dirname "$0")/config/zsh/.zshrc" "$HOME/.zshrc"
   mkdir -p "$HOME/.config/wallpapers"
   cp -r "$(dirname "$0")/wallpapers/." "$HOME/.config/wallpapers/"

   # Set zsh as default shell if not already set
   if [ "$SHELL" != "$(which zsh)" ]; then
       echo "Setting zsh as your default shell..."
       chsh -s "$(which zsh)"
   fi

   echo "Fedora setup complete."
}

install_nix() {
    echo "Detected NixOS."
    echo "Please add the following packages to your configuration.nix:"
    grep -vE '^\s*#' "$(dirname "$0")/packages/nix.txt"
    echo "NixOS setup is manual. See above for package list."

    # Copy wallpapers to ~/.config/wallpapers
    mkdir -p "$HOME/.config/wallpapers"
    cp -r "$(dirname "$0")/wallpapers/." "$HOME/.config/wallpapers/"
}

main() {
    DISTRO=$(detect_distro)
    case "$DISTRO" in
        arch)
            install_arch
            ;;
        fedora)
            install_fedora
            ;;
        nix)
            install_nix
            ;;
        *)
            echo "Unsupported or unrecognized Linux distribution."
            exit 1
            ;;
    esac
}

main "$@"
