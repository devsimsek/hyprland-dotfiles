#!/usr/bin/env bash

set -e

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
        git clone https://aur.archlinux.org/yay.git || true
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    else
        echo "yay is already installed. (good)"
    fi

    # Install packages from package list
    echo "Installing packages from packages/arch.txt..."
    yay -S --needed --noconfirm $(grep -vE '^\s*#' "$(dirname "$0")/packages/arch.txt" | xargs)

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
    sudo dnf install -y $(grep -vE '^\s*#' "$(dirname "$0")/packages/fedora.txt" | xargs)
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
