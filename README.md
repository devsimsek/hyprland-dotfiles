# Rose Pine Hyprland Dotfiles

A modern, minimal dotfiles setup for Linux, themed consistently with [Rose Pine](https://rosepinetheme.com/) across your system.
Includes configs and package lists for Arch, Fedora, and NixOS, with a focus on Hyprland, Waybar, zsh + starship, AstroNvim, and more.

## Features

- **Hyprland** (Wayland compositor) with Rose Pine theming
- **Waybar**, **nwg-dock-hyprland**, and other Wayland utilities
- **zsh** with **starship** prompt (Rose Pine theme)
- **AstroNvim** (Neovim) with Rose Pine colors
- **Kitty** terminal with Rose Pine theme
- **SDDM** Rose Pine login theme
- **GTK/Qt** apps themed with Rose Pine
- **JetBrains Mono** and other modern fonts
- **Papirus** icons, **Bibata** cursors
- **Essential utilities**: fastfetch, eza, fzf, htop, and more
- **Rose Pine wallpapers** included

## Supported Distros

- Arch Linux (with AUR support via yay)
- Fedora
- NixOS (manual package install)

## Installation

### 1. Clone the Repository

```sh
git clone https://github.com/devsimsek/hyprland-dotfiles.git
cd hyprland-dotfiles
```

### 2. Run the Install Script

```sh
bash install.sh
```

The script will:

- Detect your Linux distribution
- Install all required packages (and yay for Arch)
- Set up Rose Pine themes and configs

> **Note:**
> For NixOS, the script will print the package list for manual addition to your `configuration.nix`.

## Customization

- All configs are minimal and themed with Rose Pine.
- Wallpapers are included in the `wallpapers/` directory. Including some of my own photography and AI works.
- Package lists for each distro are in `packages/`.
- Edit configs in the `config/` directory to further personalize your setup.

## Credits

- [Rose Pine Theme](https://rosepinetheme.com/)
- [Hyprland](https://github.com/hyprwm/Hyprland)
- [AstroNvim](https://astronvim.github.io/)
- [Starship](https://starship.rs/)
- [Waybar](https://github.com/Alexays/Waybar)
- [Kitty](https://sw.kovidgoyal.net/kitty/)
- [Rose Pine Wallpapers](https://github.com/rose-pine/wallpapers)

---

Enjoy your beautiful, cohesive Linux environment!
