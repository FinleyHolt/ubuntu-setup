# Linux Setup

Automated setup script for Linux distributions (Ubuntu and Fedora) with development tools and dotfiles. Supports both full desktop installations and minimal WSL2 setups.

## Supported Distributions
- **Ubuntu 24.04+** (via APT)
- **Fedora Workstation** (via DNF)
- **WSL2** (Ubuntu or Fedora)

## Table of Contents
- [Screenshots](#screenshots)
- [Quick Start](#quick-start)
- [Setup Modes](#setup-modes)
- [Modular Architecture](#modular-architecture)
- [What Gets Installed](#what-gets-installed)
- [Distribution-Specific Notes](#distribution-specific-notes)

## Screenshots

### Clean Desktop
![Clean Desktop](assets/empty_screen.jpg)

### Desktop Overview
![Desktop Overview](assets/overview.jpg)

### Terminal
![Terminal](assets/screen_with_terminal.jpg)

## Quick Start

### 1. Install Git

```bash
sudo apt update
sudo apt install -y git
```

### 2. Set up SSH keys for GitHub

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# Start the ssh-agent
eval "$(ssh-agent -s)"

# Add your SSH key to the agent
ssh-add ~/.ssh/id_ed25519

# Display your public key
cat ~/.ssh/id_ed25519.pub
```

Add the key to GitHub:
1. Go to https://github.com/settings/keys
2. Click "New SSH key"
3. Paste your public key and save

### 3. Clone and run setup

```bash
git clone git@github.com:yourusername/linux-setup.git
cd linux-setup
chmod +x setup.sh
./setup.sh
```

The script will automatically detect your distribution (Ubuntu or Fedora) and environment (native Linux or WSL2) and present appropriate setup options.

### 4. Post-installation

After the script completes:

1. Log out and log back in for shell changes to take effect (or reboot for full desktop installs)
2. Configure Git credentials:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

## Setup Modes

The master script ([setup.sh](setup.sh)) offers three setup modes:

### 1. Full Desktop (Recommended for native Linux)
Installs everything: shell, dev tools, GUI apps, GNOME extensions, and desktop customization.

### 2. WSL2 Minimal (Recommended for WSL2)
Terminal-focused setup with:
- Zsh and dotfiles
- Neovim with full configuration
- CLI utilities (tmux, fzf, ripgrep, etc.)
- Claude Code CLI
- Optional: Micromamba, Docker

Skips: GUI apps, GNOME extensions, Ghostty, VS Code

### 3. Custom
Pick and choose individual modules to install.

## Modular Architecture

The setup is organized into focused modules for easier maintenance and flexibility:

### Module Structure
```
linux-setup/
├── setup.sh              # Master orchestration script
├── modules/
│   ├── common.sh         # Shared utilities and functions
│   ├── core.sh           # Essential packages and system updates
│   ├── shell.sh          # Zsh, Oh My Zsh, dotfiles, fonts
│   ├── dev-tools.sh      # Neovim, Docker, LaTeX, Micromamba, CLI tools
│   ├── desktop.sh        # GUI apps, GNOME extensions, customization
│   └── wsl.sh            # WSL2-specific minimal setup
```

### Running Individual Modules

You can run modules independently:

```bash
# Install just the shell configuration
./modules/shell.sh

# Install just Neovim and dev tools
./modules/dev-tools.sh

# Install just desktop components
./modules/desktop.sh
```

Each module sources `common.sh` for shared functionality and can be executed standalone.

## What Gets Installed

### Core Module ([modules/core.sh](modules/core.sh))
- System updates and essential build tools
- Git and Git LFS
- curl, wget, unzip
- Distribution-specific development packages

### Shell Module ([modules/shell.sh](modules/shell.sh))
- **Zsh** with Oh My Zsh
- Zsh plugins (syntax highlighting, autosuggestions)
- **JetBrainsMono Nerd Font** for terminal use
- Dotfiles symlinked from repository

### Dev Tools Module ([modules/dev-tools.sh](modules/dev-tools.sh))
Individual functions for selective installation:
- **Neovim** with full plugin setup (via Lazy.nvim)
  - Includes: Python, Node.js, Rust, ripgrep, fd-find, xclip
- **Docker** with Docker Compose
- **LaTeX** distribution (texlive)
- **Micromamba** for Python environment management
- **CLI utilities**: tmux, tree, htop, btop, jq, fzf, tldr, imagemagick
- **Cheat** - command-line cheatsheets
- **Claude Code CLI** and claude-history

### Desktop Module ([modules/desktop.sh](modules/desktop.sh))
Only installed on full desktop setups:
- **Ghostty terminal** with configuration (Ubuntu - manual for Fedora)
- **VS Code** with curated extensions and theme
- **GNOME Extensions**:
  - Extension Manager
  - Blur My Shell
  - Dash to Dock (customized)
  - Custom Hot Corners
- **Flatpak** with Flathub
- **GUI Applications**:
  - Browsers: Google Chrome, Microsoft Edge
  - Communication: Discord, Signal
  - Media: Spotify (Flatpak)
  - Productivity: Obsidian, Anki
- **Desktop Customization**:
  - Wallpaper configuration
  - Dock favorites
  - Yaru-blue theme

### WSL2 Module ([modules/wsl.sh](modules/wsl.sh))
Minimal terminal-focused setup:
- Core system packages
- Shell configuration
- Neovim and CLI utilities
- Claude Code CLI
- Optional: Micromamba, Docker
- WSL2-specific Git configuration

## Distribution-Specific Notes

### Ubuntu
- Uses `apt` package manager
- Neovim installed via snap
- Most applications installed from official `.deb` packages
- Ghostty installed via community installer

### Fedora
- Uses `dnf` package manager
- Neovim installed from official repos
- Some applications installed via Flatpak (Spotify, Signal, Obsidian)
- Ghostty requires manual installation (see https://ghostty.org)
- Cheat tool requires manual installation

### Package Manager Differences
The script automatically handles differences between distributions:
- **Build tools**: `build-essential` (Ubuntu) vs `@development-tools` (Fedora)
- **Python packages**: `python3-venv` (Ubuntu) vs `python3-virtualenv` (Fedora)
- **Image processing**: `imagemagick` (Ubuntu) vs `ImageMagick` (Fedora)
- **Docker**: Different repository setup for each distribution