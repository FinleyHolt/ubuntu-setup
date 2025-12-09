# Set the location of Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export EDITOR=nvim
export VISUAL=nvim

# Add ~/.local/bin to PATH for locally installed tools (claude, etc.)
export PATH="$HOME/.local/bin:$PATH"

ZSH_THEME=""

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)

# Load Oh My Zsh.
source $ZSH/oh-my-zsh.sh

# Custom prompt - username and current path relative to home
PROMPT='%n %~ %# '

alias anki="flatpak run net.ankiweb.Anki"

# Source machine-specific local configuration (not tracked in git)
# This file is created by setup-ubuntu.sh and contains micromamba initialization
if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi
