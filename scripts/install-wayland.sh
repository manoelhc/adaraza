#!/bin/sh
set -e

echo "==> Installing Wayland and related packages"

# Install Wayland core
pkg install -y \
    wayland \
    wayland-protocols \
    libxkbcommon \
    libinput \
    mesa-libs \
    mesa-dri

# Install additional Wayland utilities
pkg install -y \
    wlroots \
    xwayland \
    xorg-server

# Install graphics drivers for ARM64/Raspberry Pi
pkg install -y \
    drm-kmod \
    gpu-firmware-kmod

# Load kernel modules for ARM64 graphics
# Note: For Raspberry Pi, we use generic DRM instead of Intel i915
echo 'kld_list="evdev"' >> /etc/rc.conf

echo "==> Wayland installed successfully"
