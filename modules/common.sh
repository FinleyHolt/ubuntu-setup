#!/bin/bash

################################################################################
# Common Utilities and Functions
# Shared across all setup modules
################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_step() {
    echo -e "${BLUE}==>${NC} ${GREEN}$1${NC}"
}

print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

print_section() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  $1${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Get the directory where the main script is located
get_dotfiles_dir() {
    echo "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
}

################################################################################
# Detect Distribution
################################################################################

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        export DISTRO=$ID
        export DISTRO_VERSION=$VERSION_ID
    else
        print_error "Cannot detect Linux distribution"
        exit 1
    fi

    # Normalize distro name
    case "$DISTRO" in
        ubuntu)
            export DISTRO="ubuntu"
            export PKG_MGR="apt"
            ;;
        fedora)
            export DISTRO="fedora"
            export PKG_MGR="dnf"
            ;;
        *)
            print_error "Unsupported distribution: $DISTRO"
            echo "This script supports Ubuntu and Fedora only."
            exit 1
            ;;
    esac
}

# Detect if running in WSL
is_wsl() {
    if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
        return 0
    else
        return 1
    fi
}

################################################################################
# Package Management Wrapper Functions
################################################################################

pkg_update() {
    case "$PKG_MGR" in
        apt)
            sudo apt update
            ;;
        dnf)
            sudo dnf check-update || true
            ;;
    esac
}

pkg_upgrade() {
    case "$PKG_MGR" in
        apt)
            sudo apt upgrade -y
            ;;
        dnf)
            sudo dnf upgrade -y
            ;;
    esac
}

pkg_install() {
    case "$PKG_MGR" in
        apt)
            sudo apt install -y "$@"
            ;;
        dnf)
            sudo dnf install -y "$@"
            ;;
    esac
}

pkg_clean() {
    case "$PKG_MGR" in
        apt)
            sudo apt autoremove -y
            sudo apt autoclean
            ;;
        dnf)
            sudo dnf autoremove -y
            sudo dnf clean all
            ;;
    esac
}
