#!/bin/sh
set -e

echo "==> Installing build dependencies and development tools"

# Update package repository
pkg update -f

# Install essential build tools
pkg install -y \
    git \
    cmake \
    ninja \
    meson \
    pkgconf \
    gmake \
    autoconf \
    automake \
    libtool \
    gettext

# Install compilers
pkg install -y \
    llvm \
    gcc \
    rust

# Install additional development libraries
pkg install -y \
    python3 \
    py311-pip \
    go

echo "==> Build dependencies installed successfully"
