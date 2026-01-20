# Adaraza - Technical Overview

## Project Summary

Adaraza is an experimental FreeBSD ARM64-based operating system distribution with a modern Wayland desktop environment, designed for **Raspberry Pi 4/5**. This repository contains an automated Packer build system that creates a fully functional, bootable FreeBSD ARM64 image with Hyprland compositor and modern tools.

## Architecture

### Build System
- **Platform**: Packer (HashiCorp)
- **Virtualization**: QEMU ARM64 (qemu-system-aarch64) with KVM acceleration support
- **Base OS**: FreeBSD 14.1 ARM64
- **Target Hardware**: Raspberry Pi 4 Model B / Raspberry Pi 5
- **CPU Emulation**: ARM Cortex-A72 (compatible with Raspberry Pi 4)
- **Format**: QCOW2 disk image (convertible to raw for SD card deployment)

### Core Components

#### 1. FreeBSD Base System
- FreeBSD 14.1 RELEASE for ARM64 (aarch64)
- Stable and secure Unix-like OS
- Optimized for ARM architecture
- Full documentation at https://www.freebsd.org/

#### 2. Wayland Display Server
- Modern replacement for X11
- Better security and performance
- GPU acceleration support
- Package: `wayland`, `wayland-protocols`, `wlroots`

#### 3. Hyprland Compositor
- Dynamic tiling Wayland compositor
- Written in C++
- Highly configurable
- Beautiful animations and effects
- Configuration: `~/.config/hypr/hyprland.conf`

#### 4. uutils (Rust Coreutils)
- Drop-in replacement for GNU coreutils
- Written in Rust for memory safety
- Cross-platform compatibility
- Location: `/usr/local/bin/uutils/`
- Project: https://github.com/uutils/coreutils

#### 5. Ghostty Terminal Emulator
- Modern, GPU-accelerated terminal
- Written in Zig
- Fast and feature-rich
- Configuration: `~/.config/ghostty/config`
- Project: https://github.com/ghostty-org/ghostty

#### 6. zsh Shell
- Powerful shell with advanced features
- oh-my-zsh framework included
- Auto-completion and syntax highlighting
- Configuration: `~/.zshrc`

## File Structure

```
adaraza/
├── freebsd-wayland.pkr.hcl           # Main Packer configuration
├── freebsd-wayland.pkrvars.hcl.example  # Variable configuration template
├── builders.example.pkr.hcl           # Alternative builder examples
├── Makefile                           # Build automation
├── README.md                          # Quick start guide
├── PACKER_README.md                   # Detailed documentation
├── TROUBLESHOOTING.md                 # Common issues and solutions
├── TECHNICAL_OVERVIEW.md              # This file
└── scripts/                           # Provisioning scripts
    ├── install-build-deps.sh          # Build tools and compilers
    ├── install-wayland.sh             # Wayland display server
    ├── install-hyprland.sh            # Hyprland compositor
    ├── install-uutils.sh              # Rust coreutils
    ├── install-ghostty.sh             # Ghostty terminal
    ├── install-zsh.sh                 # zsh shell
    ├── cleanup.sh                     # System cleanup
    └── first-boot-setup.sh            # First boot initialization
```

## Build Process

The build process follows these stages:

### 1. Initialization
- Download FreeBSD ISO (if not cached)
- Verify ISO checksum
- Create virtual machine

### 2. FreeBSD Installation
- Automated installation via boot commands
- Basic system configuration
- Enable SSH for provisioning

### 3. System Updates
- Update pkg repository
- Install base packages (sudo, bash)

### 4. Development Tools (install-build-deps.sh)
- Compilers: LLVM, GCC, Rust
- Build tools: cmake, ninja, meson
- Languages: Python, Go

### 5. Wayland Installation (install-wayland.sh)
- Wayland core libraries
- wlroots compositor library
- XWayland for X11 compatibility
- Graphics drivers (DRM, i915)

### 6. Hyprland Installation (install-hyprland.sh)
- Build from source if not in ports
- Install dependencies
- Create default configuration
- Configure keybindings

### 7. uutils Installation (install-uutils.sh)
- Build from source using Cargo
- Create utility symlinks
- Add to system PATH

### 8. Ghostty Installation (install-ghostty.sh)
- Build from source using Zig
- Install GTK dependencies
- Create default configuration

### 9. zsh Configuration (install-zsh.sh)
- Install zsh and oh-my-zsh
- Configure as default shell
- Set up auto-start for Hyprland

### 10. System Cleanup (cleanup.sh)
- Lock root password
- Remove temporary files
- Clean package cache
- Create first-boot setup script
- Set hostname and services

## Security Model

### During Build
- Temporary password (`packer`) used only for SSH provisioning
- Password is locked before image finalization
- SSH keys are removed (regenerated on first boot)

### On First Boot
- User is prompted to set secure password
- First-boot setup script runs once
- Marker file prevents re-running setup

### Runtime Security
- Root password locked by default
- SSH server enabled (can be disabled)
- Standard FreeBSD security features
- User should configure firewall as needed

## Configuration

### Packer Variables
- `freebsd_version`: FreeBSD version (default: 14.1)
- `freebsd_arch`: Architecture (default: aarch64)
- `disk_size`: Disk size in MB (default: 40960)
- `memory`: RAM in MB (default: 4096)
- `cpus`: Number of CPUs (default: 2)
- `output_directory`: Output path

### QEMU ARM64 Settings
- Machine type: `virt` (ARM virtual machine)
- CPU: `cortex-a72` (Raspberry Pi 4 compatible)
- BIOS: UEFI firmware for ARM64 (`QEMU_EFI.fd`)
- Devices: virtio-gpu-pci, usb-ehci, virtio-net-pci

### Runtime Configuration Files
- `/etc/rc.conf`: System services
- `/etc/sysctl.conf`: Kernel parameters
- `~/.config/hypr/hyprland.conf`: Hyprland settings
- `~/.config/ghostty/config`: Terminal settings
- `~/.zshrc`: Shell configuration
- `~/.zprofile`: Login script (Hyprland auto-start)

## System Requirements

### Build Host
- Linux, macOS, or Windows
- Packer >= 1.8.0
- QEMU >= 5.0 with ARM64 support (qemu-system-aarch64)
- QEMU EFI firmware for ARM64 (qemu-efi-aarch64 package)
- 50GB free disk space
- 4GB+ RAM
- Internet connection
- Note: ARM64 emulation on x86_64 hosts is slower but functional

### Runtime (Guest - QEMU Emulation)
- 4GB RAM (minimum, 8GB recommended)
- 2 CPU cores (minimum, 4 recommended for better performance)
- 40GB disk space
- Virtio device support

### Runtime (Raspberry Pi Hardware)
- Raspberry Pi 4 Model B (2GB/4GB/8GB RAM variants)
- Raspberry Pi 5 (4GB/8GB RAM variants)
- MicroSD card (64GB+ recommended) or USB drive
- HDMI display
- USB keyboard and mouse
- Power supply (official recommended)
- Optional: Ethernet cable (Wi-Fi requires additional setup)

## Performance Considerations

### Build Time
- Download time depends on internet speed
- FreeBSD ARM64 installation: ~15 minutes (slightly slower than x86_64)
- Package installation: ~30-40 minutes (ARM builds take longer)
- Source builds (Hyprland, uutils, Ghostty): ~60-90 minutes (ARM compilation is slower)
- Total: ~2-3 hours on typical hardware

### Runtime Performance
- KVM acceleration recommended for ARM hosts (Linux on ARM64)
- TCG emulation on x86_64 hosts (slower but functional for testing)
- Virtio drivers for better I/O performance
- On actual Raspberry Pi 4: Good performance with hardware acceleration
- On actual Raspberry Pi 5: Excellent performance with improved GPU

### Raspberry Pi Deployment
- Image can be converted from QCOW2 to raw format for SD card
- Boot from SD card or USB drive
- Supports Raspberry Pi 4 Model B (all RAM variants: 2GB, 4GB, 8GB)
- Supports Raspberry Pi 5 (all RAM variants: 4GB, 8GB)
- Requires UEFI firmware on Raspberry Pi for FreeBSD boot

## Extending the System

### Adding Packages
1. Edit appropriate provisioning script
2. Add `pkg install -y <package-name>`
3. Rebuild image

### Custom Configuration
1. Modify configuration files in scripts
2. Add additional provisioning scripts
3. Update build block in Packer config

### Creating Variants
1. Copy `freebsd-wayland.pkr.hcl`
2. Modify provisioning steps
3. Adjust output directory

## Known Limitations

### Current Limitations
- Single-user setup (root only)
- No automated testing
- Limited hardware support testing on actual Raspberry Pi hardware
- Some components built from source (longer build time on ARM)
- ARM64 emulation on x86_64 hosts is slower (use for development/testing only)
- Raspberry Pi specific features (GPIO, etc.) not yet configured

### Raspberry Pi Specific Notes
- Tested on QEMU ARM64 emulation with Cortex-A72 CPU
- Real hardware testing on Raspberry Pi 4/5 recommended
- May require UEFI firmware update on Raspberry Pi for boot
- VideoCore GPU driver support in development
- Wi-Fi and Bluetooth drivers may need additional configuration

### Future Improvements
- Multi-user support
- Automated testing framework
- Pre-built packages for faster builds
- Cloud provider images (AWS, GCP, Azure)
- Container support
- Additional desktop environments

## Dependencies

### Build Dependencies
- Packer
- QEMU/KVM
- Internet connection

### FreeBSD Packages
See individual provisioning scripts for complete lists:
- Build tools: cmake, ninja, meson, rust, gcc
- Wayland: wayland, wlroots, libxkbcommon
- Graphics: mesa-libs, drm-kmod
- Development: git, python3, go
- Desktop: GTK4, cairo, pango

## Contributing

### Development Workflow
1. Fork repository
2. Create feature branch
3. Test changes locally
4. Submit pull request
5. Ensure scripts pass syntax checks

### Testing
```bash
# Syntax check all scripts
for script in scripts/*.sh; do
    bash -n "$script"
done

# Format Packer config
packer fmt freebsd-wayland.pkr.hcl

# Validate Packer config
packer validate freebsd-wayland.pkr.hcl
```

## Resources

### Documentation
- FreeBSD Handbook: https://docs.freebsd.org/
- Wayland Documentation: https://wayland.freedesktop.org/
- Hyprland Wiki: https://wiki.hyprland.org/
- Packer Documentation: https://www.packer.io/docs

### Community
- FreeBSD Forums: https://forums.freebsd.org/
- Hyprland Discord: https://discord.gg/hyprland
- uutils GitHub: https://github.com/uutils/coreutils

## License

This project is open source. Individual components have their own licenses:
- FreeBSD: BSD License
- Wayland: MIT License
- Hyprland: BSD-3-Clause License
- uutils: MIT License
- Ghostty: MIT License

## Acknowledgments

- FreeBSD Project Team
- Wayland Developers
- Hyprland Creator (vaxerski)
- uutils Contributors
- Ghostty Creator (mitchellh)
- HashiCorp (Packer)

## Version History

### v1.0.0 (Initial Release)
- FreeBSD 14.1 base
- Wayland + Hyprland
- uutils, Ghostty, zsh
- Automated build with Packer
- Comprehensive documentation
- Security hardening
