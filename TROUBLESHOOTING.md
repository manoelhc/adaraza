# Troubleshooting Guide for Adaraza FreeBSD ARM64 Image Builder

This guide helps resolve common issues when building and running the Adaraza FreeBSD ARM64 image for Raspberry Pi.

## Table of Contents
1. [Build Issues](#build-issues)
2. [Runtime Issues](#runtime-issues)
3. [Packer Issues](#packer-issues)
4. [FreeBSD ARM64 Specific Issues](#freebsd-arm64-specific-issues)
5. [Raspberry Pi Deployment Issues](#raspberry-pi-deployment-issues)

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

### Issue: QEMU ARM64 not available
```
Error: qemu-system-aarch64: command not found
```

**Solutions:**
1. **On Ubuntu/Debian:**
   ```bash
   sudo apt-get install qemu-system-arm qemu-efi-aarch64
   ```

2. **On macOS:**
   ```bash
   brew install qemu
   ```

3. **On Fedora/RHEL:**
   ```bash
   sudo dnf install qemu-system-aarch64 edk2-aarch64
   ```

### Issue: QEMU EFI firmware not found
```
Error: Could not open '/usr/share/qemu-efi-aarch64/QEMU_EFI.fd'
```

**Solutions:**
1. **On Ubuntu/Debian:**
   ```bash
   sudo apt-get install qemu-efi-aarch64
   ```

2. **On other systems:** Download UEFI firmware manually
   ```bash
   # Download from QEMU repository or package manager
   # Update path in freebsd-wayland.pkr.hcl to match your system
   ```

### Issue: KVM not available for ARM
```
Error: Failed to initialize build 'qemu.freebsd-wayland': kvm acceleration not available
```

**Note:** KVM acceleration for ARM64 is only available on ARM64 host machines. On x86_64 hosts, the build will use TCG emulation (slower but functional).

**Solutions:**
1. **On x86_64 hosts:** Accept slower build times with TCG emulation (remove or comment out `accelerator = "kvm"` in Packer config)
2. **On ARM64 Linux hosts:** Ensure KVM is enabled
   ```bash
   lsmod | grep kvm
   sudo modprobe kvm
   ```
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
5. Enable KVM acceleration (ARM64 Linux hosts only)

### Reduce image size
1. Clean up after installation (already done in cleanup.sh)
2. Remove unnecessary packages
3. Compress the image:
   ```bash
   qemu-img convert -c -O qcow2 input.qcow2 output-compressed.qcow2
   ```

## Raspberry Pi Deployment Issues

### Issue: Image won't boot on Raspberry Pi
**Solutions:**
1. Ensure you have UEFI firmware installed on Raspberry Pi:
   - Download and install Raspberry Pi UEFI firmware
   - Available at: https://github.com/pftf/RPi4
   - Extract to SD card boot partition before copying FreeBSD image

2. Check SD card is properly written:
   ```bash
   # Verify the image was written correctly
   sudo dd if=/dev/sdX of=verify.img bs=4M count=10
   # Compare with original
   ```

3. Use correct boot order in UEFI settings

### Issue: No video output on Raspberry Pi
**Solutions:**
1. Check HDMI cable and display
2. Try different HDMI port (Raspberry Pi 4 has 2 micro-HDMI ports)
3. Ensure VideoCore drivers are loaded:
   ```bash
   # In FreeBSD on Pi
   kldload vc4
   ```
4. Edit /boot/loader.conf to add:
   ```
   vc4_load="YES"
   ```

### Issue: Wi-Fi not working on Raspberry Pi
**Solution:**
Wi-Fi requires additional driver configuration:
```bash
# Install wireless drivers
pkg install rpi-firmware wpa_supplicant

# Configure wpa_supplicant
wpa_passphrase "SSID" "password" >> /etc/wpa_supplicant.conf

# Enable in /etc/rc.conf
echo 'wlans_brcmfmac0="wlan0"' >> /etc/rc.conf
echo 'ifconfig_wlan0="WPA DHCP"' >> /etc/rc.conf
```

### Issue: Bluetooth not working on Raspberry Pi
**Solution:**
Bluetooth support requires additional setup:
```bash
# Install Bluetooth stack
pkg install bluetooth

# Load kernel module
kldload ng_ubt

# Add to /boot/loader.conf
echo 'ng_ubt_load="YES"' >> /boot/loader.conf
```

### Issue: GPIO not accessible
**Solution:**
GPIO support on FreeBSD ARM64 is limited:
```bash
# Install GPIO utilities
pkg install libgpio

# Check available GPIO pins
gpioctl -l
```

### Issue: SD card write performance is slow
**Solutions:**
1. Use a high-quality, fast SD card (Class 10, UHS-I or better)
2. Consider using USB 3.0 SSD instead of SD card for better performance
3. Enable write caching (use with caution):
   ```bash
   sysctl vfs.write_behind=1
   ```

### Issue: ARM64 emulation is too slow for development
**Solutions:**
1. Build on ARM64 host machine if available (much faster)
2. Use cross-compilation for packages instead of building on emulated system
3. Reduce memory and CPU allocation to what you actually need
4. Consider using actual Raspberry Pi hardware for testing
5. Use pre-built packages instead of building from source when possible

## Common FreeBSD ARM64 Issues

### Issue: Package not available for ARM64
**Solution:**
Some packages may not be built for ARM64 architecture:
```bash
# Check if package exists for arm64
pkg search -o packagename

# Build from ports if necessary
cd /usr/ports/category/package
make install clean
```

### Issue: Performance is worse than expected
**Solutions:**
1. Ensure you're running on actual hardware, not emulation
2. Check CPU frequency scaling:
   ```bash
   sysctl dev.cpu | grep freq
   ```
3. Monitor system load:
   ```bash
   top
   vmstat 1
   ```
4. Check for thermal throttling on Raspberry Pi (use cooling)

### Issue: Converting image to raw format fails
**Solution:**
```bash
# Use sparse option to save space
qemu-img convert -f qcow2 -O raw -S 4k input.qcow2 output.img

# Check conversion
qemu-img info output.img
```
