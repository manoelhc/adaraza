# Adaraza FreeBSD Wayland Image Builder for Raspberry Pi

This repository contains a Packer configuration to build a FreeBSD ARM64 image with Wayland, Hyprland, and modern tools, designed for **Raspberry Pi 4/5**.

## Features

The generated image includes:

- **FreeBSD 14.1 ARM64** - Stable and secure Unix-like operating system for ARM architecture
- **Wayland** - Modern display server protocol
- **Hyprland** - Dynamic tiling Wayland compositor
- **uutils** - Rust implementation of coreutils (GNU coreutils alternative)
- **Ghostty** - Modern, fast terminal emulator
- **zsh** - Powerful shell with oh-my-zsh

## Target Hardware

- **Primary**: Raspberry Pi 4 Model B / Raspberry Pi 5
- **Architecture**: ARM64 (aarch64)
- **CPU**: ARM Cortex-A72 (Pi 4) / Cortex-A76 (Pi 5)
- **Emulation**: QEMU virt machine with Cortex-A72 CPU

## Prerequisites

To build this image, you need:

- [Packer](https://www.packer.io/) (>= 1.8.0)
- [QEMU](https://www.qemu.org/) with ARM64 support (qemu-system-aarch64)
- QEMU EFI firmware for ARM64 (qemu-efi-aarch64)
- At least 40GB of free disk space
- 4GB of RAM allocated to the VM
- Linux host with KVM support recommended (or modify the configuration for other platforms)

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

### 2. Install QEMU with ARM64 support

```bash
# On Ubuntu/Debian
sudo apt-get install qemu-system-arm qemu-efi-aarch64 qemu-utils

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
- `freebsd_arch` - Architecture (default: aarch64)
- `disk_size` - Disk size in MB (default: 40960 = 40GB)
- `memory` - RAM in MB (default: 4096 = 4GB)
- `cpus` - Number of CPUs (default: 2)
- `output_directory` - Output directory (default: output-freebsd-wayland)

### FreeBSD ISO

The default configuration uses FreeBSD 14.1 ARM64. To use a different version, update the `iso_url` and `iso_checksum` variables.

**Note**: The ISO URL points to the ARM64 (aarch64) version specifically for Raspberry Pi and ARM-based systems.

## Security

### Password Security

For security reasons, the built image has the root password locked by default. On **first login**, you will be prompted to set a new secure password. This ensures that:
- No default password exists in the distributed image
- Each installation has a unique password
- The system remains secure out of the box

**During the build process**, a temporary password (`packer`) is used only for automated provisioning and is locked before the image is finalized.

### SSH Access

- SSH server is enabled by default
- Root login via SSH is permitted (you may want to disable this in production)
- It's recommended to use SSH keys instead of password authentication

To disable root SSH login after first boot:
```bash
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
service sshd restart
```

## Usage

### Running the built image (Raspberry Pi emulation)

After building, you can run the image with QEMU ARM64:

```bash
qemu-system-aarch64 \
  -M virt \
  -cpu cortex-a72 \
  -m 4096 \
  -smp 2 \
  -drive file=output-freebsd-wayland/freebsd-wayland-14.1-aarch64,format=qcow2,if=virtio \
  -bios /usr/share/qemu-efi-aarch64/QEMU_EFI.fd \
  -device virtio-gpu-pci \
  -device usb-ehci \
  -device usb-kbd \
  -device usb-mouse \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -device virtio-net-pci,netdev=net0 \
  -display gtk,gl=on
```

Or simply use the Makefile:

```bash
make run  # Run with graphical display
make run-vnc  # Run with VNC (headless)
```

### Deploying to Raspberry Pi

To deploy the image to an actual Raspberry Pi 4/5:

1. Convert the QCOW2 image to a raw image:
```bash
qemu-img convert -f qcow2 -O raw output-freebsd-wayland/freebsd-wayland-14.1-aarch64 raspberrypi.img
```

2. Write to SD card (replace /dev/sdX with your SD card device):
```bash
sudo dd if=raspberrypi.img of=/dev/sdX bs=4M status=progress
sync
```

3. Insert SD card into Raspberry Pi and boot
  -net user
```

### Login

On first boot:
1. **Username:** root
2. **You will be prompted to set a new password** for security
3. After setting the password, Hyprland will auto-start on tty0

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
