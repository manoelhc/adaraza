#!/bin/sh
set -e

echo "==> Installing Ghostty terminal emulator"

# Install Ghostty dependencies
pkg install -y \
    gtk4 \
    libadwaita \
    vte3 \
    harfbuzz \
    fontconfig \
    freetype2

# Check if Ghostty is available in ports
if pkg search ghostty | grep -q ghostty; then
    echo "==> Installing Ghostty from ports"
    pkg install -y ghostty
else
    echo "==> Building Ghostty from source"
    
    # Install Zig compiler for building Ghostty
    if ! command -v zig > /dev/null 2>&1; then
        pkg install -y zig
    fi
    
    # Clone Ghostty repository
    cd /tmp
    git clone https://github.com/ghostty-org/ghostty.git
    cd ghostty
    
    # Build Ghostty
    zig build -Doptimize=ReleaseFast
    
    # Install Ghostty binary
    mkdir -p /usr/local/bin
    cp zig-out/bin/ghostty /usr/local/bin/
    
    # Create default config directory
    mkdir -p /root/.config/ghostty
    
    # Create basic Ghostty configuration
    cat > /root/.config/ghostty/config << 'EOF'
# Ghostty configuration for Adaraza

# Font configuration
font-family = "monospace"
font-size = 12

# Theme
theme = dark
background-opacity = 0.95

# Window settings
window-padding-x = 4
window-padding-y = 4
window-decoration = true

# Shell
shell-integration = detect
shell-integration-features = cursor,sudo,title

# Cursor
cursor-style = block
cursor-style-blink = true
EOF
    
    # Cleanup
    cd /
    rm -rf /tmp/ghostty
fi

echo "==> Ghostty installed successfully"
