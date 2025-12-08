#!/bin/bash

################################################################################
# WSL2 Setup Module
# Minimal setup for WSL2 environments (terminal-focused, no desktop components)
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

setup_wsl() {
    print_section "WSL2 Environment Setup"

    if ! is_wsl; then
        print_warning "This system does not appear to be running in WSL2"
        print_warning "WSL2 module should only be run in WSL2 environments"
        return 1
    fi

    # Core essentials
    source "$SCRIPT_DIR/core.sh"
    setup_core

    # Shell configuration (Zsh, dotfiles, fonts)
    source "$SCRIPT_DIR/shell.sh"
    setup_shell

    # Development tools (but skip some that aren't needed in WSL2)
    source "$SCRIPT_DIR/dev-tools.sh"

    # Install only the essentials for WSL2
    setup_neovim
    setup_cli_utilities
    setup_claude

    # Optionally install micromamba (useful for Python environments)
    read -p "Install Micromamba for Python environments? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_micromamba
    fi

    # Optionally install Docker (useful if you want to run containers from WSL2)
    read -p "Install Docker? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_docker
    fi

    print_section "WSL2-Specific Configuration"

    print_step "Configuring WSL2 Git credential helper..."
    # Use Windows Git credential manager from WSL2
    if command -v git &> /dev/null; then
        git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe" 2>/dev/null || true
    fi

    print_step "WSL2 setup complete!"
    echo ""
    echo "Note: WSL2 skips desktop components (GUI apps, GNOME, etc.)"
    echo "This is a minimal terminal-focused setup with Neovim and dev tools."
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    detect_distro
    setup_wsl
fi
