#!/bin/bash

readonly DOTFILES_DIR="$HOME/niri-rice/src"

install_dotfiles() {
    echo "Stowing dotfiles..."

    if [[ ! -d "$DOTFILES_DIR/.config" ]]; then
        echo "No .config directory found in $DOTFILES_DIR"
        return
    fi

    mkdir -p "$HOME/.config"

    pushd "$DOTFILES_DIR" >/dev/null
    stow --adopt -v -t "$HOME/.config" .config
    stow --adopt -v -t "$HOME" .
    popd >/dev/null

    echo "Dotfiles stowed successfully!"
}

set_zsh_default() {
    local zsh_path
    zsh_path="$(command -v zsh)"

    if [[ "${SHELL:-}" != "$zsh_path" ]]; then
        echo "Setting zsh as default shell..."
        chsh -s "$zsh_path"
        echo "Log out and back in for the change to take effect."
    else
        echo "zsh is already the default shell."
    fi
}

install_dotfiles
