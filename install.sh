#!/usr/bin/env bash

set -e

# Rose Pine Hyprland Dotfiles Installer
# -------------------------------------
SCRIPT_VERSION="1.1.0"
GITHUB_REPO="devsimsek/hyprland-dotfiles"

# Check for latest version
check_latest_version() {
    if command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
        LATEST_VERSION=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | jq -r .tag_name)
        if [ -n "$LATEST_VERSION" ] && [ "$SCRIPT_VERSION" != "$LATEST_VERSION" ]; then
            echo "A new version of this script is available: $LATEST_VERSION (you have $SCRIPT_VERSION)"
            echo "Please update by pulling the latest changes from GitHub."
        fi
    fi
}

# Detect Linux distribution
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

# Install packages for Alpine
install_alpine_packages() {
   echo "Detected Alpine Linux."
   sudo apk update

   PKGLIST="$(dirname "$0")/packages/alpine.txt"
   if [ ! -f "$PKGLIST" ]; then
       echo "ERROR: Package list $PKGLIST not found!"
       exit 1
   fi
   echo "Installing packages from $PKGLIST..."
   while read -r pkg; do
       [ -z "$pkg" ] && continue
       if apk info -e "$pkg" >/dev/null 2>&1; then
           echo "$pkg is already installed."
       else
           sudo apk add "$pkg"
       fi
   done < <(grep -vE '^\s*#' "$PKGLIST")
}

# Copy config directory or file, removing target first if needed
copy_config() {
    SRC="$1"
    DEST="$2"
    if [ -e "$DEST" ] || [ -L "$DEST" ]; then
        rm -rf "$DEST"
    fi
    if [ -d "$SRC" ]; then
        cp -r "$SRC" "$DEST"
    else
        mkdir -p "$(dirname "$DEST")"
        cp "$SRC" "$DEST"
    fi
    echo "Copied $SRC -> $DEST"
}

# Install Oh My Zsh if not present
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing Oh My Zsh..."
        RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo "Oh My Zsh already installed."
    fi
}

# Ensure starship is initialized in .zshrc
ensure_starship_zshrc() {
    if ! grep -q 'eval "$(starship init zsh)"' "$HOME/.zshrc"; then
        echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
        echo "Added starship initialization to .zshrc"
    fi
}

# Set default shell to zsh
ensure_zsh_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        echo "Setting zsh as your default shell..."
        chsh -s "$(which zsh)"
    else
        echo "zsh is already your default shell."
    fi
}

# Copy SDDM theme and set config
setup_sddm_theme() {
    THEME_SRC="$(dirname "$0")/config/sddm"
    THEME_DEST="/usr/share/sddm/themes/rose-pine"
    CONF_DIR="/etc/sddm.conf.d"
    CONF_FILE="$CONF_DIR/10-theme.conf"

    if [ -d "$THEME_SRC" ]; then
        echo "Copying SDDM theme to $THEME_DEST ..."
        sudo rm -rf "$THEME_DEST"
        sudo mkdir -p /usr/share/sddm/themes
        sudo cp -r "$THEME_SRC" "$THEME_DEST"
        echo "Setting SDDM theme to rose-pine ..."
        sudo mkdir -p "$CONF_DIR"
        echo -e "[Theme]\nCurrent=rose-pine" | sudo tee "$CONF_FILE" >/dev/null
        if [ -d "$THEME_DEST" ]; then
            echo "SDDM theme installed successfully."
        else
            echo "ERROR: Failed to install SDDM theme."
        fi
    else
        echo "WARNING: SDDM theme source not found at $THEME_SRC"
    fi
}

# Copy wallpapers
copy_wallpapers() {
    SRC="$(dirname "$0")/wallpapers"
    DEST="$HOME/.config/wallpapers"
    mkdir -p "$DEST"
    cp -r "$SRC/." "$DEST/"
    echo "Wallpapers copied to $DEST"
}

# Copy all configs except nvim (handled separately)
copy_all_configs() {
    BASEDIR="$(dirname "$0")/config"
    DESTDIR="$HOME/.config"

    mkdir -p "$DESTDIR"
    copy_config "$BASEDIR/kitty" "$DESTDIR/kitty"
    copy_config "$BASEDIR/hypr" "$DESTDIR/hypr"
    copy_config "$BASEDIR/waybar" "$DESTDIR/waybar"
    copy_config "$BASEDIR/rofi" "$DESTDIR/rofi"
    copy_config "$BASEDIR/starship" "$DESTDIR/starship"
    copy_config "$BASEDIR/swaync" "$DESTDIR/swaync"
    copy_config "$BASEDIR/qt6ct" "$DESTDIR/qt6ct"
    copy_config "$BASEDIR/gtk-3.0" "$DESTDIR/gtk-3.0"
    copy_config "$BASEDIR/zsh/.zshrc" "$HOME/.zshrc"
}

# Install AstroNvim and overlay custom config if present
install_astronvim() {
    NVIM_DEST="$HOME/.config/nvim"
    CUSTOM_NVIM_SRC="$(dirname "$0")/config/nvim"

    if [ ! -d "$NVIM_DEST" ] || [ -z "$(ls -A "$NVIM_DEST" 2>/dev/null)" ]; then
        echo "Installing AstroNvim..."
        git clone --depth 1 https://github.com/AstroNvim/AstroNvim "$NVIM_DEST"
    else
        echo "Neovim config directory already exists at $NVIM_DEST"
    fi

    # Overlay custom config if present and not empty
    if [ -d "$CUSTOM_NVIM_SRC" ] && [ "$(ls -A "$CUSTOM_NVIM_SRC")" ]; then
        echo "Overlaying custom Neovim config..."
        cp -r "$CUSTOM_NVIM_SRC/." "$NVIM_DEST/"
    fi
}

# Install packages for Arch
install_arch_packages() {
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
            echo "$pkg is already installed."
        else
            yay -S --noconfirm "$pkg"
        fi
    done < <(grep -vE '^\s*#' "$PKGLIST")
}

# Install packages for Fedora
install_fedora_packages() {
    echo "Detected Fedora."
    sudo dnf upgrade -y

    # Enable Copr repo for starship if not already enabled
    if ! rpm -q starship &>/dev/null; then
        sudo dnf install -y 'dnf-command(copr)'
        sudo dnf copr enable atim/starship -y
    fi

    PKGLIST="$(dirname "$0")/packages/fedora.txt"
    if [ ! -f "$PKGLIST" ]; then
        echo "ERROR: Package list $PKGLIST not found!"
        exit 1
    fi
    echo "Installing packages from $PKGLIST..."
    while read -r pkg; do
        [ -z "$pkg" ] && continue
        if rpm -q "$pkg" &>/dev/null; then
            echo "$pkg is already installed."
        else
            sudo dnf install -y "$pkg"
        fi
    done < <(grep -vE '^\s*#' "$PKGLIST")
}

# NixOS: print package list and copy wallpapers
nix_instructions() {
    echo "Detected NixOS."
    echo "Please add the following packages to your configuration.nix:"
    grep -vE '^\s*#' "$(dirname "$0")/packages/nix.txt"
    echo "NixOS setup is manual. See above for package list."
    copy_wallpapers
}

# Main install logic
main() {
    check_latest_version

    DISTRO=$(detect_distro)
    case "$DISTRO" in
        arch)
            install_arch_packages
            setup_sddm_theme
            copy_all_configs
            install_astronvim
            copy_wallpapers
            install_oh_my_zsh
            ensure_zsh_shell
            ensure_starship_zshrc
            echo "Enabling and starting SDDM display manager..."
            sudo systemctl enable sddm
            sudo systemctl start sddm
            echo "Arch Linux setup complete."
            ;;
        fedora)
            install_fedora_packages
            setup_sddm_theme
            copy_all_configs
            install_astronvim
            copy_wallpapers
            install_oh_my_zsh
            ensure_zsh_shell
            ensure_starship_zshrc
            echo "Enabling and starting SDDM display manager..."
            sudo systemctl enable sddm
            sudo systemctl start sddm
            echo "Fedora setup complete."
            ;;
        alpine)
            install_alpine_packages
            setup_sddm_theme
            copy_all_configs
            install_astronvim
            copy_wallpapers
            install_oh_my_zsh
            ensure_zsh_shell
            ensure_starship_zshrc
            echo "Enabling and starting SDDM display manager (OpenRC)..."
            sudo rc-update add sddm default
            sudo rc-service sddm start
            echo "Alpine Linux setup complete."
            ;;
        nix)
            nix_instructions
            ;;
        *)
            echo "Unsupported or unrecognized Linux distribution."
            exit 1
            ;;
    esac

    echo
    echo "--------------------------------------------"
    echo " Rose Pine Hyprland Dotfiles setup complete!"
    echo " Please reboot or re-login for all changes to take effect."
    echo "--------------------------------------------"
}

main "$@"
