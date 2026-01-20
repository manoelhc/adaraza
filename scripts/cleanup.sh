#!/bin/sh
set -e

echo "==> Performing system cleanup"

# Security: Lock the root password (disable password login)
# Users should set a new password on first login or use SSH keys
echo "==> Locking root password for security"
passwd -l root

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

FIRST LOGIN: You will be prompted to set a secure password.

To start Hyprland, login and it will auto-start on tty0
Or manually run: Hyprland

Default user: root
Default shell: zsh

EOF

# Install first-boot setup script
cat > /usr/local/bin/adaraza-first-boot << 'FIRSTBOOT'
#!/bin/sh
# First boot initialization script for Adaraza
FIRST_BOOT_FLAG="/root/.adaraza_first_boot_done"

if [ -f "$FIRST_BOOT_FLAG" ]; then
    exit 0
fi

echo "======================================================================"
echo "  Welcome to Adaraza - First Boot Setup"
echo "======================================================================"
echo ""
echo "For security, please set a new root password:"
echo ""

# Prompt for new password
passwd root

if [ $? -eq 0 ]; then
    echo ""
    echo "Password set successfully!"
    touch "$FIRST_BOOT_FLAG"
    echo ""
    echo "======================================================================"
    echo "  Setup Complete!"
    echo "======================================================================"
    echo ""
    echo "You can now use your new password to login."
    echo "To start Hyprland, simply logout and login again (auto-starts on tty0)"
    echo ""
else
    echo ""
    echo "Warning: Password not changed. Please run 'passwd' manually."
    echo ""
fi
FIRSTBOOT

chmod +x /usr/local/bin/adaraza-first-boot

# Add first-boot script to root's profile
echo '' >> /root/.zprofile
echo '# First boot setup' >> /root/.zprofile
echo 'if [ ! -f /root/.adaraza_first_boot_done ]; then' >> /root/.zprofile
echo '    /usr/local/bin/adaraza-first-boot' >> /root/.zprofile
echo 'fi' >> /root/.zprofile

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
