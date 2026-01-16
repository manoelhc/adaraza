# Troubleshooting Guide for Adaraza FreeBSD Image Builder

This guide helps resolve common issues when building and running the Adaraza FreeBSD image.

## Table of Contents
1. [Build Issues](#build-issues)
2. [Runtime Issues](#runtime-issues)
3. [Packer Issues](#packer-issues)
4. [FreeBSD Specific Issues](#freebsd-specific-issues)

## Build Issues

### Issue: Packer plugin not installed
```
Error: Missing plugins
The following plugins are required, but not installed:
* github.com/hashicorp/qemu >= 1.0.0
```

**Solution:**
```bash
packer init freebsd-wayland.pkr.hcl
```

### Issue: QEMU/KVM not available
```
Error: Failed to initialize build 'qemu.freebsd-wayland': kvm acceleration not available
```

**Solutions:**
1. **On Linux:** Ensure KVM is enabled
   ```bash
   # Check if KVM is available
   lsmod | grep kvm
   
   # If not, load the module
   sudo modprobe kvm
   sudo modprobe kvm_intel  # or kvm_amd for AMD processors
   
   # Add your user to the kvm group
   sudo usermod -aG kvm $USER
   # Log out and back in for changes to take effect
   ```

2. **On macOS/Windows:** Change accelerator in freebsd-wayland.pkr.hcl
   ```hcl
   # For macOS
   accelerator = "hvf"
   
   # For Windows
   accelerator = "whpx"
   
   # Or disable acceleration (slower)
   accelerator = "none"
   ```

### Issue: Insufficient disk space
```
Error: Failed to create disk image: No space left on device
```

**Solutions:**
1. Free up disk space (need at least 50GB)
2. Change output directory to a partition with more space:
   ```bash
   packer build -var 'output_directory=/path/to/larger/disk/output' freebsd-wayland.pkr.hcl
   ```

### Issue: Network timeout during ISO download
```
Error: Error downloading ISO: context deadline exceeded
```

**Solutions:**
1. Pre-download the ISO and use local path:
   ```bash
   wget https://download.freebsd.org/releases/amd64/amd64/ISO-IMAGES/14.1/FreeBSD-14.1-RELEASE-amd64-disc1.iso
   ```
   
   Then modify the Packer config:
   ```hcl
   iso_url = "file:///path/to/FreeBSD-14.1-RELEASE-amd64-disc1.iso"
   ```

2. Increase timeout (edit packer config):
   ```hcl
   http_timeout = "1h"  # Add this to source block
   ```

### Issue: Build hangs during provisioning
```
Build is stuck at "Waiting for SSH to become available..."
```

**Solutions:**
1. Check if SSH port is reachable:
   ```bash
   # In another terminal
   netstat -an | grep 22
   ```

2. Increase SSH timeout in config:
   ```hcl
   ssh_timeout = "60m"  # Increase from 30m
   ssh_handshake_attempts = 200  # Increase from 100
   ```

3. Run with debug mode:
   ```bash
   PACKER_LOG=1 packer build freebsd-wayland.pkr.hcl
   ```

### Issue: Script execution fails
```
Error: Script exited with non-zero exit status: 1
```

**Solutions:**
1. Check script syntax:
   ```bash
   bash -n scripts/script-name.sh
   ```

2. Run script manually in a FreeBSD VM to debug

3. Add debugging to scripts:
   ```bash
   # Add to top of problematic script
   set -x  # Print commands as they execute
   ```

## Runtime Issues

### Issue: Image won't boot
**Solutions:**
1. Check QEMU command:
   ```bash
   qemu-system-x86_64 \
     -m 4096 \
     -smp 2 \
     -drive file=output-freebsd-wayland/freebsd-wayland-14.1,format=qcow2 \
     -boot c \
     -display gtk
   ```

2. Verify image integrity:
   ```bash
   qemu-img check output-freebsd-wayland/freebsd-wayland-14.1
   ```

### Issue: Hyprland won't start
```
Error: Failed to create Wayland display
```

**Solutions:**
1. Check if running in correct environment:
   ```bash
   echo $XDG_SESSION_TYPE  # Should be 'wayland'
   ```

2. Check Hyprland logs:
   ```bash
   cat /tmp/hypr/$(ls -t /tmp/hypr | head -1)/hyprland.log
   ```

3. Verify Wayland installation:
   ```bash
   pkg info | grep wayland
   ```

4. Check kernel modules:
   ```bash
   kldstat | grep drm
   ```

### Issue: Graphics not working / Black screen
**Solutions:**
1. Use different graphics settings in QEMU:
   ```bash
   qemu-system-x86_64 \
     -m 4096 \
     -drive file=output-freebsd-wayland/freebsd-wayland-14.1,format=qcow2 \
     -vga std  # Try: std, cirrus, vmware, qxl, virtio
   ```

2. Enable software rendering:
   ```bash
   export LIBGL_ALWAYS_SOFTWARE=1
   Hyprland
   ```

### Issue: Keyboard/mouse not working in VM
**Solutions:**
1. Add USB tablet device to QEMU:
   ```bash
   qemu-system-x86_64 \
     ... \
     -usb \
     -device usb-tablet
   ```

2. Use different input device:
   ```bash
   -device virtio-keyboard-pci \
   -device virtio-mouse-pci
   ```

## Packer Issues

### Issue: Packer version mismatch
```
Error: Unsupported Packer Core version
```

**Solution:**
Update Packer to latest version:
```bash
# On Linux
wget https://releases.hashicorp.com/packer/<VERSION>/packer_<VERSION>_linux_amd64.zip
unzip packer_<VERSION>_linux_amd64.zip
sudo mv packer /usr/local/bin/

# Or use package manager
```

### Issue: Invalid HCL syntax
```
Error: Invalid expression
```

**Solutions:**
1. Validate configuration:
   ```bash
   packer validate freebsd-wayland.pkr.hcl
   ```

2. Format configuration:
   ```bash
   packer fmt freebsd-wayland.pkr.hcl
   ```

## FreeBSD Specific Issues

### Issue: Package installation fails
```
pkg: Repository FreeBSD has unsupported version
```

**Solution:**
Update pkg:
```bash
pkg bootstrap -f
pkg update -f
```

### Issue: Kernel module won't load
```
Error: Could not load kernel module drm
```

**Solutions:**
1. Check if module exists:
   ```bash
   find /boot/modules -name "*drm*"
   ```

2. Install graphics drivers:
   ```bash
   pkg install drm-kmod gpu-firmware-kmod
   ```

3. Load module manually:
   ```bash
   kldload /boot/modules/i915kms.ko
   ```

### Issue: uutils not in PATH
**Solution:**
Add to shell configuration:
```bash
echo 'export PATH="/usr/local/bin/uutils:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Issue: Ghostty won't compile
**Solutions:**
1. Ensure Zig is installed:
   ```bash
   pkg install zig
   ```

2. Check Zig version:
   ```bash
   zig version  # Should be 0.11.0 or higher
   ```

3. Build with verbose output:
   ```bash
   zig build -Doptimize=ReleaseFast --verbose
   ```

## Getting More Help

### Enable Debug Logging
```bash
# Packer debug
PACKER_LOG=1 PACKER_LOG_PATH=packer.log packer build freebsd-wayland.pkr.hcl

# Check system logs
dmesg | tail -50
cat /var/log/messages
```

### Report Issues
If you encounter issues not covered here:
1. Check existing GitHub issues
2. Provide:
   - Packer version (`packer version`)
   - QEMU version (`qemu-system-x86_64 --version`)
   - Host OS and version
   - Full error message
   - Relevant logs

### Community Resources
- FreeBSD Forums: https://forums.freebsd.org/
- Hyprland Discord: https://discord.gg/hyprland
- Packer Documentation: https://www.packer.io/docs

## Performance Tips

### Speed up builds
1. Use local mirror for FreeBSD packages
2. Pre-download ISO
3. Increase allocated resources:
   ```bash
   packer build -var 'memory=8192' -var 'cpus=4' freebsd-wayland.pkr.hcl
   ```
4. Use SSD for output directory
5. Enable KVM acceleration (Linux only)

### Reduce image size
1. Clean up after installation (already done in cleanup.sh)
2. Remove unnecessary packages
3. Compress the image:
   ```bash
   qemu-img convert -c -O qcow2 input.qcow2 output-compressed.qcow2
   ```
