# Alternative Builder Configuration Examples
# This file shows how to use different builders instead of QEMU

# Uncomment and modify the sections below to use alternative builders

# =============================================================================
# VirtualBox Builder
# =============================================================================
# Requires VirtualBox to be installed
# Uncomment the source block below and comment out the QEMU source in freebsd-wayland.pkr.hcl

/*
source "virtualbox-iso" "freebsd-wayland" {
  vm_name              = "freebsd-wayland-${var.freebsd_version}"
  iso_url              = var.iso_url
  iso_checksum         = var.iso_checksum
  output_directory     = var.output_directory
  disk_size            = var.disk_size
  memory               = var.memory
  cpus                 = var.cpus
  guest_os_type        = "FreeBSD_64"
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
    "echo 'root:packer' | chpasswd<enter><wait>",
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
    "echo 'root:packer' | chpasswd<enter><wait>",
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
# Notes on Builder Selection
# =============================================================================
# 
# QEMU:
#   - Best for Linux hosts with KVM support
#   - Fastest build times on Linux
#   - Cross-platform support (with slower performance without KVM)
#   - Output: QCOW2 image format
#
# VirtualBox:
#   - Good cross-platform support (Windows, macOS, Linux)
#   - Free and open source
#   - Easy to use for testing
#   - Output: OVF/OVA format
#
# VMware:
#   - Professional/enterprise environments
#   - Best performance on Windows/macOS
#   - Requires commercial license
#   - Output: VMX/VMDK format
#
# To use a different builder:
# 1. Install the required software (VirtualBox or VMware)
# 2. Copy the appropriate source block above
# 3. Replace the QEMU source in freebsd-wayland.pkr.hcl
# 4. Run packer init and packer build as normal
