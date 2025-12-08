#!/bin/bash

################################################################################
# Core System Setup Module
# Essential packages and system updates
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

setup_core() {
    print_section "Core System Setup"

    print_step "Updating system packages..."
    pkg_update
    pkg_upgrade

    print_step "Installing essential build tools and dependencies..."
    if [ "$DISTRO" = "ubuntu" ]; then
        pkg_install \
            build-essential \
            git \
            git-lfs \
            curl \
            wget \
            unzip \
            ca-certificates \
            gnupg \
            lsb-release \
            software-properties-common \
            apt-transport-https
    elif [ "$DISTRO" = "fedora" ]; then
        pkg_install \
            @development-tools \
            git \
            git-lfs \
            curl \
            wget \
            unzip \
            ca-certificates \
            gnupg2 \
            redhat-lsb-core
    fi

    print_step "Core system setup complete"
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    detect_distro
    setup_core
fi
