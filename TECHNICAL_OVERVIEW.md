# Adaraza - Technical Overview

## Project Summary

Adaraza is an experimental FreeBSD-based operating system distribution with a modern Wayland desktop environment. This repository contains an automated Packer build system that creates a fully functional, bootable FreeBSD image with Hyprland compositor and modern tools.

## Architecture

### Build System
- **Platform**: Packer (HashiCorp)
- **Virtualization**: QEMU (with KVM acceleration support)
- **Base OS**: FreeBSD 14.1
- **Format**: QCOW2 disk image

### Core Components

#### 1. FreeBSD Base System
- FreeBSD 14.1 RELEASE
- Stable and secure Unix-like OS
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
- `disk_size`: Disk size in MB (default: 40960)
- `memory`: RAM in MB (default: 4096)
- `cpus`: Number of CPUs (default: 2)
- `output_directory`: Output path

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
- QEMU >= 5.0
- 50GB free disk space
- 4GB+ RAM
- Internet connection

### Runtime (Guest)
- 4GB RAM (minimum)
- 2 CPU cores (minimum)
- 40GB disk space
- VT-x/AMD-V virtualization support
- OpenGL support (for graphics acceleration)

## Performance Considerations

### Build Time
- Download time depends on internet speed
- FreeBSD installation: ~10 minutes
- Package installation: ~20-30 minutes
- Source builds (Hyprland, uutils, Ghostty): ~30-60 minutes
- Total: ~1-2 hours

### Runtime Performance
- KVM acceleration recommended (Linux hosts)
- HVF acceleration for macOS
- Virtio drivers for better I/O performance
- GPU passthrough for better graphics (optional)

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
- Limited hardware support testing
- Some components built from source (longer build time)

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
