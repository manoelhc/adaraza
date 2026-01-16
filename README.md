# adaraza
New OS Distro experiment

## Overview

Adaraza is an experimental OS distribution based on FreeBSD with a modern Wayland desktop environment featuring Hyprland compositor and cutting-edge tools.

## Building the Image

This repository includes a Packer configuration to build a complete FreeBSD image with:
- Wayland display server
- Hyprland compositor
- uutils (Rust coreutils)
- Ghostty terminal emulator
- zsh shell

### Quick Start

```bash
# Install dependencies
make check-deps

# Build the image
make build

# Run the image
make run
```

For detailed documentation, see [PACKER_README.md](PACKER_README.md)
