#!/bin/sh
set -e

echo "==> Performing system cleanup"

# Clean package cache
pkg clean -y

# Remove unnecessary files
rm -rf /tmp/*
rm -rf /var/tmp/*

# Clean build artifacts
rm -rf /root/.cache/*

# Remove SSH keys (will be regenerated on first boot)
rm -f /etc/ssh/ssh_host_*

# Create a welcome message
cat > /etc/motd << 'EOF'
 █████╗ ██████╗  █████╗ ██████╗  █████╗ ███████╗ █████╗ 
██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗╚══███╔╝██╔══██╗
███████║██║  ██║███████║██████╔╝███████║  ███╔╝ ███████║
██╔══██║██║  ██║██╔══██║██╔══██╗██╔══██║ ███╔╝  ██╔══██║
██║  ██║██████╔╝██║  ██║██║  ██║██║  ██║███████╗██║  ██║
╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

Welcome to Adaraza - FreeBSD with Wayland, Hyprland, and modern tools

Installed components:
  - FreeBSD (base system)
  - Wayland (display server)
  - Hyprland (compositor)
  - uutils (Rust coreutils in /usr/local/bin/uutils)
  - Ghostty (terminal emulator)
  - zsh (default shell)

To start Hyprland, login and it will auto-start on tty0
Or manually run: Hyprland

Default user: root
Default shell: zsh

EOF

# Set system hostname
echo 'hostname="adaraza"' >> /etc/rc.conf

# Enable necessary services
echo 'dbus_enable="YES"' >> /etc/rc.conf

# Configure system for graphical environment
cat > /etc/sysctl.conf << 'EOF'
# Increase shared memory for Wayland
kern.ipc.shm_allow_removed=1
kern.ipc.shmmax=67108864
kern.ipc.shmall=32768
EOF

echo "==> System cleanup and configuration completed"
echo "==> Image is ready for use"
