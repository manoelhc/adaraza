# Alternative Builder Configuration Examples for ARM64
# This file shows how to use different builders instead of QEMU for ARM64/Raspberry Pi

# Note: Most virtualization platforms have limited ARM64 support
# QEMU is the recommended option for ARM64 emulation and Raspberry Pi development

# Uncomment and modify the sections below to use alternative builders

# =============================================================================
# QEMU ARM64 Builder (Default - Recommended)
# =============================================================================
# This is the default configuration in freebsd-wayland.pkr.hcl
# Supports ARM64 emulation with Cortex-A72 CPU (Raspberry Pi 4 compatible)

# =============================================================================
# VirtualBox Builder (Limited ARM64 Support)
# =============================================================================
# Note: VirtualBox has very limited ARM64 guest support
# Not recommended for FreeBSD ARM64 - use QEMU instead
# Only uncomment if you have VirtualBox 7.0+ with ARM64 support

/*
source "virtualbox-iso" "freebsd-wayland" {
  vm_name              = "freebsd-wayland-${var.freebsd_version}-${var.freebsd_arch}"
  iso_url              = var.iso_url
  iso_checksum         = var.iso_checksum
  output_directory     = var.output_directory
  disk_size            = var.disk_size
  memory               = var.memory
  cpus                 = var.cpus
  guest_os_type        = "FreeBSD_64"
  headless             = false
  
  boot_wait = "30s"
  boot_command = [
    "<wait10><wait10><wait10>",
    "<enter><wait10><wait10>",
    "<enter><wait>",
    "<enter><wait>",
    "<down><down><down><down><down><down><down><down><down><down><enter><wait>",
    "<enter><wait>",
    "<enter><wait>",
    "<wait10><wait10><wait10><wait10><wait10>",
    "<enter><wait>",
    "root<enter><wait>",
    "mkdir -p /root/.ssh<enter><wait>",
    "echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config<enter><wait>",
    "echo 'packer' | pw usermod root -h 0<enter><wait>",
    "service sshd restart<enter><wait>"
  ]
  
  ssh_username         = "root"
  ssh_password         = "packer"
  ssh_timeout          = "30m"
  
  shutdown_command = "shutdown -p now"
  shutdown_timeout = "5m"
  
  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--vram", "128"],
    ["modifyvm", "{{.Name}}", "--graphicscontroller", "vmsvga"]
  ]
}
*/

# =============================================================================
# VMware Builder
# =============================================================================
# Requires VMware Workstation/Fusion to be installed
# Uncomment the source block below and comment out the QEMU source in freebsd-wayland.pkr.hcl

/*
source "vmware-iso" "freebsd-wayland" {
  vm_name              = "freebsd-wayland-${var.freebsd_version}"
  iso_url              = var.iso_url
  iso_checksum         = var.iso_checksum
  output_directory     = var.output_directory
  disk_size            = var.disk_size
  memory               = var.memory
  cpus                 = var.cpus
  guest_os_type        = "freebsd-64"
  headless             = false
  
  boot_wait = "10s"
  boot_command = [
    "<enter><wait10><wait10><wait10>",
    "<enter><wait>",
    "<enter><wait>",
    "<down><down><down><down><down><down><down><down><down><down><enter><wait>",
    "<enter><wait>",
    "<enter><wait>",
    "<wait10><wait10><wait10><wait10><wait10>",
    "<enter><wait>",
    "root<enter><wait>",
    "mkdir -p /root/.ssh<enter><wait>",
    "echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config<enter><wait>",
    "echo 'packer' | pw usermod root -h 0<enter><wait>",
    "service sshd restart<enter><wait>"
  ]
  
  ssh_username         = "root"
  ssh_password         = "packer"
  ssh_timeout          = "30m"
  
  shutdown_command = "shutdown -p now"
  shutdown_timeout = "5m"
  
  vmx_data = {
    "virtualHW.version"                = "14"
    "svga.autodetect"                  = "TRUE"
    "svga.vramSize"                    = "134217728"
  }
}
*/

# =============================================================================
# Notes on Builder Selection for ARM64
# =============================================================================
# 
# QEMU (Recommended):
#   - Best option for ARM64 emulation
#   - Supports ARM Cortex-A72 CPU emulation (Raspberry Pi 4/5 compatible)
#   - Works on x86_64 and ARM64 host machines
#   - KVM acceleration available on ARM64 Linux hosts
#   - TCG emulation on x86_64 hosts (slower but functional)
#   - Output: QCOW2 image format (convertible to raw for SD card)
#   - Most mature ARM64 virtualization solution
#
# VirtualBox:
#   - Limited ARM64 guest support (experimental in VirtualBox 7.0+)
#   - Not recommended for FreeBSD ARM64 development
#   - Better to use QEMU instead
#
# VMware:
#   - Very limited ARM64 guest support
#   - Not recommended for ARM64 workloads
#   - Use QEMU instead
#
# For Raspberry Pi Development:
# 1. Use QEMU for initial development and testing
# 2. Convert QCOW2 to raw image for SD card deployment
# 3. Test on actual Raspberry Pi hardware
# 4. QEMU emulation is slower than real hardware but accurate
#
# To use a different builder:
# 1. Check if the builder supports ARM64 guests
# 2. Install the required software
# 3. Copy the appropriate source block above
# 4. Replace the QEMU source in freebsd-wayland.pkr.hcl
# 5. Run packer init and packer build as normal
#
# Performance Notes:
# - ARM64 emulation on x86_64: ~10-20x slower than native
# - ARM64 with KVM on ARM64 host: Near-native performance
# - Actual Raspberry Pi 4: Good performance for daily use
# - Actual Raspberry Pi 5: Excellent performance
