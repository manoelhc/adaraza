# adaraza
New OS Distro experiment

## Overview

Adaraza is an experimental OS distribution based on FreeBSD ARM64 with a modern Wayland desktop environment featuring Hyprland compositor and cutting-edge tools. **Designed for Raspberry Pi 4/5**.

## Building the Image

This repository includes a Packer configuration to build a complete FreeBSD ARM64 image with:
- Wayland display server
- Hyprland compositor
- uutils (Rust coreutils)
- Ghostty terminal emulator
- zsh shell

### Target Hardware
- **Primary**: Raspberry Pi 4 / Raspberry Pi 5
- **Architecture**: ARM64 (aarch64)
- **Emulation**: QEMU with ARM Cortex-A72 CPU

### Quick Start

```bash
# Install dependencies (includes ARM64 QEMU and EFI firmware)
make check-deps

# Build the image
make build

# Run the image (emulates Raspberry Pi)
make run
```

For detailed documentation, see [PACKER_README.md](PACKER_README.md)
