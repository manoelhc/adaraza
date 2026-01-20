#!/bin/sh
set -e

echo "==> Installing and configuring zsh"

# Install zsh
pkg install -y zsh

# Install oh-my-zsh for enhanced zsh experience
cd /tmp
git clone https://github.com/ohmyzsh/ohmyzsh.git
cd ohmyzsh/tools
sh install.sh --unattended

# Create zsh configuration
cat > /root/.zshrc << 'EOF'
# Zsh configuration for Adaraza

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(git rust)

source $ZSH/oh-my-zsh.sh

# User configuration

# Add uutils to PATH (optional)
export PATH="/usr/local/bin/uutils:$PATH"

# Aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

# Environment variables
export EDITOR='vi'
export VISUAL='vi'

# Wayland environment
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland
EOF

# Set zsh as default shell for root
chsh -s /usr/local/bin/zsh root

# Create a startup script for Hyprland
cat > /root/.zprofile << 'EOF'
# Auto-start Hyprland on login
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/ttyv0" ]; then
    exec Hyprland
fi
EOF

echo "==> zsh installed and configured successfully"
