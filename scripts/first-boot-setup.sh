#!/bin/sh
# First boot initialization script for Adaraza
# This script runs once on the first boot to set up the system

FIRST_BOOT_FLAG="/root/.adaraza_first_boot_done"

if [ -f "$FIRST_BOOT_FLAG" ]; then
    # Already initialized
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

# Enable root login if password was set successfully
if [ $? -eq 0 ]; then
    echo ""
    echo "Password set successfully!"
    echo ""
    
    # Create flag file to prevent running again
    touch "$FIRST_BOOT_FLAG"
    
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
