# Niri Rice

> Personal dotfiles and setup scripts for a Niri-based Arch Linux desktop.

## Overview

A collection of configuration files and automated scripts to bootstrap and rice an Arch Linux desktop running the [Niri](https://github.com/YaLTeR/niri) scrollable tiling Wayland compositor, themed with [Catppuccin Mocha](https://github.com/catppuccin/catppuccin).

## Components

| Component | Description |
|-----------|-------------|
| **Niri** | Scrollable tiling Wayland compositor — modular config split into keybinds, display, layout, rules, input, animations, and autostart |
| **Noctalia** | Shell / bar / launcher / lock screen / wallpaper manager for Niri (Catppuccin Mocha palette) |
| **Kitty** | GPU-accelerated terminal with JetBrainsMono Nerd Font, Catppuccin Mocha theme, transparency, and cursor trail |
| **Neovim** | Editor configured with [lazy.nvim](https://github.com/folke/lazy.nvim) — Catppuccin theme, Treesitter, LSP, Telescope, Neo-tree, Lualine, and more |
| **Fastfetch** | System info fetch with custom layout and Kitty image protocol support |
| **Zsh** | Shell config (CachyOS base) with Powerlevel10k prompt |
| **IdeaVim** | Vim keybindings for JetBrains IDEs |

## Structure

```
src/
├── .config/
│   ├── niri/              # Niri compositor config (KDL)
│   │   ├── config.kdl     # Main config (includes cfg/*.kdl)
│   │   ├── cfg/           # Modular config fragments
│   │   └── scripts/       # Monitor setup & helpers
│   ├── noctalia/          # Noctalia shell settings, colors & plugins
│   ├── kitty/             # Kitty terminal config (Catppuccin Mocha)
│   ├── nvim/              # Neovim config (lazy.nvim)
│   │   ├── init.lua
│   │   └── lua/
│   │       ├── vim-options.lua
│   │       ├── plugins.lua
│   │       └── plugins/   # Plugin specs (catppuccin, lsp, telescope, …)
│   ├── fastfetch/         # Fastfetch config & assets
│   └── scripts/           # General utility scripts (PiP toggle, …)
├── .zshrc
├── .p10k.zsh
└── .ideavimrc
scripts/
├── install.sh             # Interactive package installer
└── apply_configs.sh       # Symlink dotfiles via GNU Stow
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
- **AUR** — IDEs, gaming, and extra AUR packages
  - *Important* — Rider, IntelliJ IDEA Ultimate, Vesktop
  - *Rice* — theming extras
  - *Applications* — additional apps
  - *Gaming* — Path of Building, Awakened PoE Trade

### 3. Apply configs

```bash
bash ~/niri-rice/scripts/apply_configs.sh
```

This uses [GNU Stow](https://www.gnu.org/software/stow/) to symlink everything from `src/` into your home directory, sets scripts as executable, and configures Zsh as the default shell.

## TODO

- [ ] SDDM Theme
- [ ] Wallpapers
- [ ] swww
- [ ] Wlogout
- [ ] File Explorer
- [ ] Waybar
- [ ] Scripts for Waybar