# Adaraza FreeBSD Wayland Image Builder

This repository contains a Packer configuration to build a FreeBSD image with Wayland, Hyprland, and modern tools.

## Features

The generated image includes:

- **FreeBSD 14.1** - Stable and secure Unix-like operating system
- **Wayland** - Modern display server protocol
- **Hyprland** - Dynamic tiling Wayland compositor
- **uutils** - Rust implementation of coreutils (GNU coreutils alternative)
- **Ghostty** - Modern, fast terminal emulator
- **zsh** - Powerful shell with oh-my-zsh

## Prerequisites

To build this image, you need:

- [Packer](https://www.packer.io/) (>= 1.8.0)
- [QEMU](https://www.qemu.org/) (for virtualization)
- At least 40GB of free disk space
- 4GB of RAM allocated to the VM
- Linux host with KVM support (or modify the configuration for other platforms)

## Quick Start

### 1. Install Packer

```bash
# On Ubuntu/Debian
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install packer

# On macOS
brew install packer
```

### 2. Install QEMU

```bash
# On Ubuntu/Debian
sudo apt-get install qemu-system-x86 qemu-utils

# On macOS
brew install qemu
```

### 3. Initialize Packer plugins

```bash
packer init freebsd-wayland.pkr.hcl
```

### 4. Build the image

```bash
packer build freebsd-wayland.pkr.hcl
```

The build process will:
1. Download the FreeBSD 14.1 ISO
2. Create a virtual machine
3. Install FreeBSD
4. Install and configure all components
5. Create a QCOW2 image in the `output-freebsd-wayland` directory

## Configuration

### Variables

You can customize the build by passing variables:

```bash
packer build \
  -var 'disk_size=81920' \
  -var 'memory=8192' \
  -var 'cpus=4' \
  freebsd-wayland.pkr.hcl
```

Available variables:
- `freebsd_version` - FreeBSD version (default: 14.1)
- `freebsd_arch` - Architecture (default: amd64)
- `disk_size` - Disk size in MB (default: 40960 = 40GB)
- `memory` - RAM in MB (default: 4096 = 4GB)
- `cpus` - Number of CPUs (default: 2)
- `output_directory` - Output directory (default: output-freebsd-wayland)

### FreeBSD ISO

The default configuration uses FreeBSD 14.1. To use a different version, update the `iso_url` and `iso_checksum` variables.

## Usage

### Running the built image

After building, you can run the image with QEMU:

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -m 4096 \
  -smp 2 \
  -drive file=output-freebsd-wayland/freebsd-wayland-14.1,format=qcow2 \
  -display gtk,gl=on \
  -vga virtio \
  -net nic,model=virtio \
  -net user
```

### Login

- **Username:** root
- **Password:** packer (or configured during build)

### Starting Hyprland

Hyprland is configured to auto-start on the first virtual console (tty0). Simply log in, and it will start automatically. If it doesn't auto-start:

```bash
Hyprland
```

### Using the components

**Ghostty Terminal:**
- Press `Super + Return` to open Ghostty terminal
- Configuration: `~/.config/ghostty/config`

**Hyprland:**
- Configuration: `~/.config/hypr/hyprland.conf`
- Key bindings:
  - `Super + Return` - Open terminal
  - `Super + Q` - Close window
  - `Super + Shift + E` - Exit Hyprland
  - `Super + F` - Toggle fullscreen
  - `Super + V` - Toggle floating
  - `Super + 1-5` - Switch workspaces

**uutils:**
- Located in `/usr/local/bin/uutils/`
- Added to PATH for easy access
- Use as drop-in replacements for standard coreutils

**zsh:**
- Default shell with oh-my-zsh
- Configuration: `~/.zshrc`

## Architecture

### Packer Configuration

The main Packer file (`freebsd-wayland.pkr.hcl`) defines:
- Source configuration (QEMU)
- Build variables
- Provisioning steps

### Provisioning Scripts

Located in the `scripts/` directory:

1. **install-build-deps.sh** - Installs compilers, build tools, and development dependencies
2. **install-wayland.sh** - Installs Wayland server and related libraries
3. **install-hyprland.sh** - Builds and configures Hyprland compositor
4. **install-uutils.sh** - Builds and installs Rust coreutils
5. **install-ghostty.sh** - Builds and configures Ghostty terminal
6. **install-zsh.sh** - Installs and configures zsh with oh-my-zsh
7. **cleanup.sh** - Performs system cleanup and final configuration

## Troubleshooting

### Build Issues

**QEMU/KVM not available:**
If you're not on Linux or don't have KVM, modify the Packer configuration:
```hcl
accelerator = "none"  # or "hvf" for macOS, "whpx" for Windows
```

**Insufficient disk space:**
The build requires significant space. Ensure you have at least 50GB free.

**Network timeout during build:**
Increase the `ssh_timeout` value in the Packer configuration.

### Runtime Issues

**Graphics not working:**
Ensure your QEMU installation includes virtio and OpenGL support.

**Hyprland won't start:**
Check the logs:
```bash
cat /tmp/hypr/$(ls -t /tmp/hypr | head -1)/hyprland.log
```

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This project is open source. See individual component licenses for details.

## Credits

- FreeBSD Project
- Wayland Project
- Hyprland
- uutils/coreutils
- Ghostty
- Oh My Zsh

## Roadmap

Future enhancements:
- [ ] Add more Wayland compositors (Sway, River)
- [ ] Include additional terminal emulators
- [ ] Add desktop applications
- [ ] Support for multiple architectures
- [ ] Cloud image variants (AWS, Azure, GCP)
- [ ] Docker/container support
