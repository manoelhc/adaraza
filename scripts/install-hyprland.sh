#!/bin/sh
set -e

echo "==> Installing Hyprland compositor"

# Install Hyprland dependencies
pkg install -y \
    cairo \
    pango \
    pixman \
    libdrm \
    libglvnd \
    libxcb \
    xcb-util \
    xcb-util-errors \
    xcb-util-keysyms \
    xcb-util-renderutil \
    xcb-util-wm

# Check if Hyprland is available in ports
if pkg search hyprland | grep -q hyprland; then
    echo "==> Installing Hyprland from ports"
    pkg install -y hyprland
else
    echo "==> Building Hyprland from source"
    
    # Clone Hyprland repository
    cd /tmp
    git clone --recursive https://github.com/hyprwm/Hyprland.git
    cd Hyprland
    
    # Install additional dependencies for building
    pkg install -y \
        tomlplusplus \
        hyprlang \
        hyprwayland-scanner
    
    # Build Hyprland
    meson setup build
    ninja -C build
    ninja -C build install
    
    # Cleanup
    cd /
    rm -rf /tmp/Hyprland
fi

# Create default Hyprland config directory
mkdir -p /root/.config/hypr

# Create basic Hyprland configuration
cat > /root/.config/hypr/hyprland.conf << 'EOF'
# Hyprland configuration for Adaraza

# Monitor configuration
monitor=,preferred,auto,1

# Execute at launch
exec-once = ghostty

# Input configuration
input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = false
    }
    sensitivity = 0
}

# General settings
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

# Decoration
decoration {
    rounding = 10
    blur {
        enabled = true
        size = 3
        passes = 1
    }
    drop_shadow = true
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

# Animations
animations {
    enabled = true
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# Keybindings
$mainMod = SUPER

bind = $mainMod, RETURN, exec, ghostty
bind = $mainMod, Q, killactive,
bind = $mainMod SHIFT, E, exit,
bind = $mainMod, V, togglefloating,
bind = $mainMod, F, fullscreen,

# Move focus
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Switch workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5

# Move window to workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
EOF

echo "==> Hyprland installed and configured successfully"
