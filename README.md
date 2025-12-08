# Linux Setup

Automated setup script for Linux distributions (Ubuntu and Fedora) with development tools and dotfiles.

## Supported Distributions
- **Ubuntu 24.04+** (via APT)
- **Fedora Workstation** (via DNF)

## Table of Contents
- [Screenshots](#screenshots)
- [Quick Start](#quick-start)
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
chmod +x setup-linux.sh
./setup-linux.sh
```

The script will automatically detect your distribution (Ubuntu or Fedora) and install packages accordingly.

### 4. Post-installation

After the script completes:

1. Log out and log back in for shell changes to take effect
2. Configure Git credentials:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

## What Gets Installed

### Core Tools
- **Zsh** with Oh My Zsh and plugins (syntax highlighting, autosuggestions)
- **JetBrainsMono Nerd Font** for terminal use
- **Ghostty terminal** (Ubuntu only - manual installation required for Fedora)
- **Neovim** with full plugin setup
- **VS Code** with curated extensions

### Development Tools
- **Micromamba** for Python environment management
- **Docker** with Docker Compose
- **Node.js** (LTS version)
- **Rust** toolchain
- **LaTeX** distribution
- **Git** with Git LFS

### GNOME Desktop Enhancements
- GNOME Extension Manager
- Blur My Shell
- Dash to Dock
- Custom Hot Corners

### Applications
- **Browsers**: Google Chrome, Microsoft Edge
- **Communication**: Discord, Signal, Spotify
- **Productivity**: Obsidian, Anki
- **Utilities**: tmux, fzf, btop, htop, ripgrep, fd-find, tldr, cheat

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