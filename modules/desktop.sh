#!/bin/bash

################################################################################
# Desktop Environment Module
# GUI applications, GNOME extensions, terminal emulator, and desktop customization
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

setup_ghostty() {
    print_section "Ghostty Terminal"

    DOTFILES_DIR="$(get_dotfiles_dir)"

    print_step "Installing Ghostty terminal..."
    if ! command -v ghostty &> /dev/null; then
        if [ "$DISTRO" = "ubuntu" ]; then
            # Install Ghostty using the community .deb package installer
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
        elif [ "$DISTRO" = "fedora" ]; then
            # For Fedora, we'll need to build from source or use a COPR repo
            print_warning "Ghostty installation on Fedora requires manual installation"
            print_warning "Please visit: https://ghostty.org for installation instructions"
        fi
        print_step "Ghostty installation completed or skipped"
    else
        print_step "Ghostty is already installed"
    fi

    print_step "Linking Ghostty configuration..."
    mkdir -p "$HOME/.config/ghostty"
    if [ ! -L "$HOME/.config/ghostty/config" ] || [ "$(readlink "$HOME/.config/ghostty/config")" != "$DOTFILES_DIR/ghostty/config" ]; then
        [ -f "$HOME/.config/ghostty/config" ] && [ ! -L "$HOME/.config/ghostty/config" ] && mv "$HOME/.config/ghostty/config" "$HOME/.config/ghostty/config.backup.$(date +%Y%m%d_%H%M%S)"
        ln -sf "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"
    fi

    print_step "Ghostty setup complete"
}

setup_vscode() {
    print_section "Visual Studio Code"

    print_step "Installing Visual Studio Code..."
    if ! command -v code &> /dev/null; then
        if [ "$DISTRO" = "ubuntu" ]; then
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
            sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
            sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
            rm -f packages.microsoft.gpg
            pkg_update
            pkg_install code
        elif [ "$DISTRO" = "fedora" ]; then
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
            pkg_update
            pkg_install code
        fi
    fi

    print_step "Installing VS Code extensions..."
    code --install-extension anthropic.claude-code --force
    code --install-extension tyriar.theme-sapphire --force
    code --install-extension ms-python.python --force
    code --install-extension ms-python.vscode-pylance --force
    code --install-extension ms-toolsai.jupyter --force
    code --install-extension docker.docker --force
    code --install-extension ms-azuretools.vscode-docker --force
    code --install-extension james-yu.latex-workshop --force
    code --install-extension efoerster.texlab --force
    code --install-extension bierner.markdown-mermaid --force
    code --install-extension mechatroner.rainbow-csv --force
    code --install-extension ms-vscode.makefile-tools --force
    code --install-extension ms-vscode.cpptools --force
    code --install-extension redhat.vscode-yaml --force

    print_step "Removing GitHub Copilot (if installed)..."
    code --uninstall-extension GitHub.copilot 2>/dev/null || true

    print_step "Configuring VS Code settings..."
    mkdir -p "$HOME/.config/Code/User"

    # Only set theme if settings.json doesn't exist or doesn't have the theme set
    if [ ! -f "$HOME/.config/Code/User/settings.json" ]; then
        # Set Sapphire theme and disable AI features in VS Code settings using Python to ensure valid JSON
        python3 << 'PYEOF'
import json
import os

settings_path = os.path.expanduser("~/.config/Code/User/settings.json")

# Create new settings with Sapphire theme and AI features disabled
settings = {
    "workbench.colorTheme": "Sapphire",
    "claudeCode.preferredLocation": "panel",
    "chat.disableAIFeatures": True,
    "github.copilot.enable": {
        "*": False
    },
    "editor.inlineSuggest.enabled": False,
    "editor.suggest.showInlineCompletions": False,
    "workbench.enableExperiments": False,
    "extensions.experimental.affinity": {
        "github.copilot": 0,
        "github.copilot-chat": 0
    }
}

# Write settings
with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=4)
PYEOF
    else
        print_step "VS Code settings already exist, skipping theme configuration"
    fi

    print_step "VS Code setup complete"
}

setup_gnome_extensions() {
    print_section "GNOME Extensions"

    print_step "Installing GNOME Extension Manager..."
    if [ "$DISTRO" = "ubuntu" ]; then
        pkg_install gnome-shell-extension-manager
    elif [ "$DISTRO" = "fedora" ]; then
        pkg_install gnome-extensions-app
    fi

    print_step "Installing chrome-gnome-shell for browser integration..."
    if [ "$DISTRO" = "ubuntu" ]; then
        pkg_install chrome-gnome-shell
    elif [ "$DISTRO" = "fedora" ]; then
        pkg_install chrome-gnome-shell
    fi

    print_step "Installing gnome-extensions-cli for automated extension installation..."
    if ! command -v gnome-extensions-cli &> /dev/null; then
        pip3 install --user gnome-extensions-cli --break-system-packages 2>/dev/null || pip3 install --user gnome-extensions-cli
    fi

    print_step "Disabling Ubuntu Dock to avoid conflicts with Dash to Dock..."
    gnome-extensions disable ubuntu-dock@ubuntu.com 2>/dev/null || true

    print_step "Installing GNOME extensions..."
    # Install extensions using gnome-extensions-cli (will skip if already installed)
    ~/.local/bin/gext install blur-my-shell@aunetx 2>/dev/null || true
    ~/.local/bin/gext install dash-to-dock@micxgx.gmail.com 2>/dev/null || true
    ~/.local/bin/gext install custom-hot-corners-extended@G-dH.github.com 2>/dev/null || true

    print_step "Enabling GNOME extensions..."
    gnome-extensions enable blur-my-shell@aunetx 2>/dev/null || true
    gnome-extensions enable dash-to-dock@micxgx.gmail.com 2>/dev/null || true
    gnome-extensions enable custom-hot-corners-extended@G-dH.github.com 2>/dev/null || true

    print_step "Configuring Custom Hot Corners..."
    # Set bottom-right corner to toggle overview
    dconf write /org/gnome/shell/extensions/custom-hot-corners-extended/monitor-0-bottom-right-0/action "'toggle-overview'"

    print_step "Configuring Dash to Dock..."
    # Set dock height to 100 pixels
    gsettings set org.gnome.shell.extensions.dash-to-dock height-fraction 1.0
    # Enable autohide when windows maximize (dock-fixed must be false)
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
    gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
    # Set max icon size to 48
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48
    gsettings set org.gnome.shell.extensions.dash-to-dock icon-size-fixed true
    # Set background opacity to fixed at 20% with white color
    gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
    gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.2
    gsettings set org.gnome.shell.extensions.dash-to-dock custom-background-color true
    gsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(255,255,255)'
    # Disable overview on startup (replaces no-overview extension)
    gsettings set org.gnome.shell.extensions.dash-to-dock disable-overview-on-startup true

    print_step "GNOME extensions installed and enabled"
    echo "Note: You may need to restart GNOME Shell (Alt+F2, type 'r', press Enter) or log out for extensions to fully activate"
}

setup_flatpak_apps() {
    print_section "Flatpak and Applications"

    print_step "Setting up Flatpak..."
    if [ "$DISTRO" = "ubuntu" ]; then
        pkg_install flatpak gnome-software-plugin-flatpak
    elif [ "$DISTRO" = "fedora" ]; then
        # Flatpak is usually pre-installed on Fedora Workstation
        pkg_install flatpak
    fi
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    print_step "Installing Flatpak applications..."
    flatpak install -y flathub net.ankiweb.Anki

    print_step "Flatpak setup complete"
}

setup_gui_apps() {
    print_section "Additional Applications"

    print_step "Installing Google Chrome..."
    if ! command -v google-chrome &> /dev/null; then
        if [ "$DISTRO" = "ubuntu" ]; then
            cd /tmp
            wget -q --show-progress https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
            pkg_install ./google-chrome-stable_current_amd64.deb
            rm google-chrome-stable_current_amd64.deb
            cd -
        elif [ "$DISTRO" = "fedora" ]; then
            cd /tmp
            wget -q --show-progress https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
            pkg_install ./google-chrome-stable_current_x86_64.rpm
            rm google-chrome-stable_current_x86_64.rpm
            cd -
        fi
    fi

    print_step "Installing Microsoft Edge..."
    if ! command -v microsoft-edge &> /dev/null; then
        if [ "$DISTRO" = "ubuntu" ]; then
            curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-edge.gpg > /dev/null
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
            pkg_update
            pkg_install microsoft-edge-stable
        elif [ "$DISTRO" = "fedora" ]; then
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge
            pkg_install microsoft-edge-stable
        fi
    fi

    print_step "Installing Discord..."
    if ! command -v discord &> /dev/null; then
        if [ "$DISTRO" = "ubuntu" ]; then
            cd /tmp
            wget -q --show-progress "https://discord.com/api/download?platform=linux&format=deb" -O discord.deb
            pkg_install ./discord.deb
            rm discord.deb
            cd -
        elif [ "$DISTRO" = "fedora" ]; then
            cd /tmp
            wget -q --show-progress "https://discord.com/api/download?platform=linux&format=tar.gz" -O discord.tar.gz
            sudo tar -xzf discord.tar.gz -C /opt
            sudo ln -sf /opt/Discord/Discord /usr/bin/discord
            rm discord.tar.gz
            cd -
        fi
    fi

    print_step "Installing Spotify..."
    if ! command -v spotify &> /dev/null; then
        # Use Flatpak for both distributions (simpler and more reliable)
        flatpak install -y flathub com.spotify.Client
    fi

    print_step "Installing Signal..."
    if ! command -v signal-desktop &> /dev/null; then
        if [ "$DISTRO" = "ubuntu" ]; then
            wget -qO- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main" | sudo tee /etc/apt/sources.list.d/signal-xenial.list
            pkg_update
            pkg_install signal-desktop
        elif [ "$DISTRO" = "fedora" ]; then
            # Use Flatpak for Signal on Fedora
            flatpak install -y flathub org.signal.Signal
        fi
    fi

    print_step "Installing Obsidian..."
    if ! command -v obsidian &> /dev/null; then
        if [ "$DISTRO" = "ubuntu" ]; then
            cd /tmp
            wget -q --show-progress "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.7.7/obsidian_1.7.7_amd64.deb" -O obsidian.deb
            pkg_install ./obsidian.deb
            rm obsidian.deb
            cd -
        elif [ "$DISTRO" = "fedora" ]; then
            # Use Flatpak for Obsidian on Fedora
            flatpak install -y flathub md.obsidian.Obsidian
        fi
    fi

    print_step "GUI applications installation complete"
}

setup_desktop_customization() {
    print_section "Desktop Customization"

    DOTFILES_DIR="$(get_dotfiles_dir)"

    print_step "Setting desktop wallpaper..."
    # Check for wallpaper in assets folder first, then root directory
    if [ -f "$DOTFILES_DIR/assets/wallpaper.jpg" ]; then
        WALLPAPER_PATH="$DOTFILES_DIR/assets/wallpaper.jpg"
    elif [ -f "$DOTFILES_DIR/assets/wallpaper.jpeg" ]; then
        WALLPAPER_PATH="$DOTFILES_DIR/assets/wallpaper.jpeg"
    elif [ -f "$DOTFILES_DIR/assets/wallpaper.png" ]; then
        WALLPAPER_PATH="$DOTFILES_DIR/assets/wallpaper.png"
    elif [ -f "$DOTFILES_DIR/wallpaper.jpg" ]; then
        WALLPAPER_PATH="$DOTFILES_DIR/wallpaper.jpg"
    elif [ -f "$DOTFILES_DIR/wallpaper.jpeg" ]; then
        WALLPAPER_PATH="$DOTFILES_DIR/wallpaper.jpeg"
    elif [ -f "$DOTFILES_DIR/wallpaper.png" ]; then
        WALLPAPER_PATH="$DOTFILES_DIR/wallpaper.png"
    fi

    if [ -n "$WALLPAPER_PATH" ] && [ -f "$WALLPAPER_PATH" ]; then
        gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_PATH"
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER_PATH"
        gsettings set org.gnome.desktop.background picture-options "zoom"
        print_step "Wallpaper set successfully"
    else
        print_warning "Wallpaper file not found (tried wallpaper.jpg and wallpaper.jpeg)"
    fi

    print_step "Configuring dock favorites..."
    # Detect the correct Discord desktop file name (could be discord.desktop or discord_discord.desktop for snap)
    DISCORD_DESKTOP="discord.desktop"
    if [ -f "/var/lib/snapd/desktop/applications/discord_discord.desktop" ]; then
        DISCORD_DESKTOP="discord_discord.desktop"
    fi
    gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'com.mitchellh.ghostty.desktop', 'google-chrome.desktop', '$DISCORD_DESKTOP', 'spotify.desktop', 'microsoft-edge.desktop', 'code.desktop', 'signal-desktop.desktop', 'obsidian.desktop']"

    print_step "Setting accent color to blue..."
    # Ubuntu 24.04 uses Yaru theme variants for accent colors
    gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-blue'
    gsettings set org.gnome.desktop.interface icon-theme 'Yaru-blue'

    print_step "Hiding home folder icon from desktop..."
    gsettings set org.gnome.shell.extensions.ding show-home false 2>/dev/null || true

    print_step "Desktop customization complete"
}

# Main function to run all desktop setup
setup_desktop() {
    setup_ghostty
    setup_vscode
    setup_gnome_extensions
    setup_flatpak_apps
    setup_gui_apps
    setup_desktop_customization
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    detect_distro
    setup_desktop
fi
