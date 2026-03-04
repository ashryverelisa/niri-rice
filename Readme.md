# Niri Rice

> Personal dotfiles and setup scripts for a Niri-based Arch Linux desktop.

## Overview

A collection of configuration files and automated scripts to bootstrap and rice an Arch Linux desktop running the [Niri](https://github.com/YaLTeR/niri) scrollable tiling Wayland compositor.

## Components

| Component | Description |
|-----------|-------------|
| **Niri** | Scrollable tiling Wayland compositor — modular config split into keybinds, display, layout, rules, input, animations, and autostart |
| **Kitty** | GPU-accelerated terminal with JetBrainsMono Nerd Font, transparency, and cursor trail |
| **Fastfetch** | System info fetch with custom layout and Kitty image protocol support |
| **Zsh** | Shell config (CachyOS base) with Powerlevel10k prompt |
| **IdeaVim** | Vim keybindings for JetBrains IDEs |

## Structure

```
src/
├── .config/
│   ├── niri/           # Niri compositor config (KDL)
│   │   ├── config.kdl  # Main config (includes cfg/*.kdl)
│   │   ├── cfg/        # Modular config fragments
│   │   └── scripts/    # Monitor setup & helpers
│   ├── kitty/          # Kitty terminal config
│   ├── fastfetch/      # Fastfetch config & assets
│   └── scripts/        # General utility scripts
├── .zshrc
├── .p10k.zsh
└── .ideavimrc
scripts/
├── install.sh          # Interactive package installer
└── apply_configs.sh    # Symlink dotfiles via GNU Stow
```

## Installation

> [!IMPORTANT]
> Designed for **Arch Linux** (or Arch-based distros like CachyOS). An AUR helper (`yay` or `paru`) is required for AUR packages.

### 1. Clone the repository

```bash
git clone https://github.com/<user>/niri-rice.git ~/niri-rice
```

### 2. Install packages

```bash
bash ~/niri-rice/scripts/install.sh
```

The interactive installer lets you choose which package groups to install:
- **System** — core tools (kitty, stow, …)
- **Applications** — daily-use apps
- **Rice** — theming & cosmetics
- **AUR** — IDE, gaming, and extra AUR packages

### 3. Apply configs

```bash
bash ~/niri-rice/scripts/apply_configs.sh
```

This uses [GNU Stow](https://www.gnu.org/software/stow/) to symlink everything from `src/` into your home directory.


# TODO
- [ ] Custom Scripts
- [ ] Niri Animations
- [ ] Niri Rules
- [ ] Niri Layouts
- [ ] neovim
- [ ] SDDM Theme
- [ ] Wallpapers
- [ ] swww?
- [ ] Wlogout?
- [ ] File Explorer