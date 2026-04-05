#!/bin/bash

readonly RESET=$'\e[0m'
readonly BLUE=$'\e[34m'
readonly GREEN=$'\e[32m'
readonly YELLOW=$'\e[33m'
readonly RED=$'\e[31m'

log() {
    local level=$1 color=$2
    shift 2
    printf "%b[%s]%b %s\n" "$color" "$level" "$RESET" "$*"
}

info()    { log INFO    "$BLUE"   "$@"; }
success() { log SUCCESS "$GREEN"  "$@"; }
warn()    { log WARN    "$YELLOW" "$@"; }
error()   { log ERROR   "$RED"    "$@"; }

ask_yes_no() {
    local reply
    read -r -p "$1 [Y/n]: " reply
    reply=${reply,,}
    [[ -z "$reply" || "$reply" =~ ^y(es)?$ ]] 
}

select_aur_helper() {
    PS3="$(printf "%bEnter choice (default 1): %b")"

    select helper in yay paru; do
        AUR_HELPER="${helper:-yay}"
        break
    done

    if ! command -v "$AUR_HELPER" >/dev/null 2>&1; then
        printf "%bError:%b %s is not installed.\n"
        exit 1
    fi

    printf "%bUsing %s as AUR helper%b\n"
}

echo -e "\n────────────────────────────────────────────"
echo -e "       Package Installation Script"
echo -e "────────────────────────────────────────────\n"

INSTALL_SYSTEM=false
INSTALL_APPLICATIONS=false
INSTALL_RICE=false

if ask_yes_no "Install System packages?"; then
    INSTALL_SYSTEM=true
fi

if ask_yes_no "Install Application packages?"; then
    INSTALL_APPLICATIONS=true
fi

if ask_yes_no "Install Rice packages?"; then
    INSTALL_RICE=true
fi

INSTALL_AUR=false
if ask_yes_no "Install AUR packages?"; then
    INSTALL_AUR=true
    select_aur_helper

    INSTALL_AUR_SYSTEM=false
    INSTALL_AUR_RICE=false
    INSTALL_AUR_APPS=false
    INSTALL_AUR_GAMING=false

    if ask_yes_no "  Install Important AUR packages?"; then
        INSTALL_AUR_SYSTEM=true
    fi

    if ask_yes_no "  Install Rice AUR packages?"; then
        INSTALL_AUR_RICE=true
    fi

    if ask_yes_no "  Install Application AUR packages?"; then
        INSTALL_AUR_APPS=true
    fi
    
    if ask_yes_no "  Install Gaming AUR packages?"; then
        INSTALL_AUR_GAMING=true
    fi
fi

echo -e "\n Starting installation...\n"

# PACKAGE DEFINITIONS 
System_Packages=(

)

Application_Packages=(
  # container 
  docker
  docker-compose
  
  # creative
  gimp
  
  # media players
  vlc
  mpv
  
  # office
  libreoffice-still
  
  # sdk and tools
  dotnet-sdk
  
  # markdown
  obsidian
  
  # engine
  godot-mono
  
  # recording
  obs-studio
)
  
Rice_Packages=(
  # terminal
  kitty
  
  # shell utilities
  btop
  cava
  htop
  lolcat
  neovim
  fastfetch
  cowsay
  cmatrix
)
  
Aur_Packages=(

)  
  
Aur_App_Packages=(
  # communication
  vesktop
    
  # ide
  rider
  intellij-idea-ultimate-edition
)

Aur_Rice_Packages=(
  sddm-silent-theme
)
  
Aur_Gaming_Packages=(
  path-of-building-community-git
  awakened-poe-trade-git
)

# Installation
Final_Packages=()

[ "$INSTALL_SYSTEM" = true ] && {
    info "Including System packages"
    Final_Packages+=("${System_Packages[@]}")
}

[ "$INSTALL_APPLICATIONS" = true ] && {
    info "Including Application packages"
    Final_Packages+=("${Application_Packages[@]}")
}

[ "$INSTALL_RICE" = true ] && {
    info "Including Rice packages"
    Final_Packages+=("${Rice_Packages[@]}")
}

if [ ${#Final_Packages[@]} -gt 0 ]; then
    info "Installing ${#Final_Packages[@]} official packages"

    if sudo pacman -Syu --needed "${Final_Packages[@]}"; then
        success "Official packages installed successfully"
    else
        error "Some official packages failed to install"
    fi
else
    warn "No official packages selected"
fi

if [ "$INSTALL_AUR" = true ]; then
    Aur_Final_Packages=()

    [ "$INSTALL_AUR_SYSTEM" = true ] && {
        info "Including Important AUR packages"
        Aur_Final_Packages+=("${Aur_Packages[@]}")
    }

    [ "$INSTALL_AUR_RICE" = true ] && {
        info "Including Rice AUR packages"
        Aur_Final_Packages+=("${Aur_Rice_Packages[@]}")
    }

    [ "$INSTALL_AUR_APPS" = true ] && {
        info "Including Application AUR packages"
        Aur_Final_Packages+=("${Aur_App_Packages[@]}")
    }

    [ "$INSTALL_AUR_GAMING" = true ] && {
        info "Including Gaming AUR packages"
        Aur_Final_Packages+=("${Aur_Gaming_Packages[@]}")
    }

    if [ ${#Aur_Final_Packages[@]} -gt 0 ]; then
        info "Installing ${#Aur_Final_Packages[@]} AUR packages using $AUR_HELPER"

        if "$AUR_HELPER" -S --needed "${Aur_Final_Packages[@]}"; then
            success "AUR packages installed successfully"
        else
            error "Some AUR packages failed to install"
        fi
    else
        warn "No AUR packages selected"
    fi
fi

printf "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
printf "          Installation Complete!\n"
printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"