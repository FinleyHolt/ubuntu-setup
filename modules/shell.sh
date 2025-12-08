#!/bin/bash

################################################################################
# Shell Configuration Module
# Zsh, Oh My Zsh, and dotfiles setup
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

setup_shell() {
    print_section "Shell Configuration"

    DOTFILES_DIR="$(get_dotfiles_dir)"

    print_step "Installing Zsh..."
    pkg_install zsh

    print_step "Installing Oh My Zsh..."
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    print_step "Installing Zsh plugins..."
    # zsh-syntax-highlighting
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
            ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi

    # zsh-autosuggestions
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi

    print_step "Linking zshrc configuration..."
    if [ ! -L "$HOME/.zshrc" ] || [ "$(readlink "$HOME/.zshrc")" != "$DOTFILES_DIR/zshrc" ]; then
        [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        ln -sf "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
    fi

    print_step "Installing JetBrainsMono Nerd Font..."
    if ! fc-list | grep -q "JetBrainsMono Nerd Font"; then
        mkdir -p "$HOME/.local/share/fonts"
        cd /tmp
        wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip
        unzip -o JetBrainsMono.zip -d "$HOME/.local/share/fonts/" > /dev/null
        rm JetBrainsMono.zip
        fc-cache -fv > /dev/null
        cd "$DOTFILES_DIR"
    else
        print_step "JetBrainsMono Nerd Font is already installed"
    fi

    print_step "Setting Zsh as default shell..."
    if [ "$SHELL" != "$(which zsh)" ]; then
        chsh -s "$(which zsh)"
        print_warning "Default shell changed to Zsh. Please log out and log back in for changes to take effect."
    fi

    print_step "Shell configuration complete"
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    detect_distro
    setup_shell
fi
