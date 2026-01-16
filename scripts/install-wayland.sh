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

# Install graphics drivers
pkg install -y \
    drm-kmod \
    gpu-firmware-kmod

# Load kernel modules
echo 'kld_list="i915kms"' >> /etc/rc.conf

echo "==> Wayland installed successfully"
