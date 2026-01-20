packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "freebsd_version" {
  type    = string
  default = "14.1"
}

variable "freebsd_arch" {
  type    = string
  default = "aarch64"
}

variable "iso_url" {
  type    = string
  default = "https://download.freebsd.org/releases/arm64/aarch64/ISO-IMAGES/14.1/FreeBSD-14.1-RELEASE-arm64-aarch64-disc1.iso"
}

variable "iso_checksum" {
  type = string
  # To get the actual checksum, visit:
  # https://download.freebsd.org/releases/arm64/aarch64/ISO-IMAGES/14.1/CHECKSUM.SHA256-FreeBSD-14.1-RELEASE-arm64-aarch64
  # Or use "none" to skip checksum verification (not recommended for production)
  default = "sha256:e5e1f7e8f7e8f7e8f7e8f7e8f7e8f7e8f7e8f7e8f7e8f7e8f7e8f7e8f7e8f7e8"
}

variable "disk_size" {
  type    = string
  default = "40960"
}

variable "memory" {
  type    = string
  default = "4096"
}

variable "cpus" {
  type    = string
  default = "2"
}

variable "output_directory" {
  type    = string
  default = "output-freebsd-wayland"
}

source "qemu" "freebsd-wayland" {
  vm_name          = "freebsd-wayland-${var.freebsd_version}-${var.freebsd_arch}"
  iso_url          = var.iso_url
  iso_checksum     = var.iso_checksum
  output_directory = var.output_directory
  disk_size        = var.disk_size
  memory           = var.memory
  cpus             = var.cpus
  accelerator      = "kvm"
  format           = "qcow2"
  net_device       = "virtio-net"
  disk_interface   = "virtio"
  headless         = false

  # ARM64-specific QEMU settings for Raspberry Pi emulation
  qemuargs = [
    ["-machine", "virt"],
    ["-cpu", "cortex-a72"],
    ["-bios", "/usr/share/qemu-efi-aarch64/QEMU_EFI.fd"],
    ["-device", "virtio-gpu-pci"],
    ["-device", "usb-ehci"],
    ["-device", "usb-kbd"],
    ["-device", "usb-mouse"]
  ]

  # Boot command for FreeBSD ARM64 installer
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

  ssh_username           = "root"
  ssh_password           = "packer"
  ssh_timeout            = "30m"
  ssh_handshake_attempts = 100

  shutdown_command = "shutdown -p now"
  shutdown_timeout = "5m"
}

build {
  sources = ["source.qemu.freebsd-wayland"]

  # Update system and install base packages
  provisioner "shell" {
    inline = [
      "pkg update -f",
      "pkg install -y sudo bash"
    ]
  }

  # Install build dependencies and development tools
  provisioner "shell" {
    script = "scripts/install-build-deps.sh"
  }

  # Install and configure Wayland
  provisioner "shell" {
    script = "scripts/install-wayland.sh"
  }

  # Install Hyprland compositor
  provisioner "shell" {
    script = "scripts/install-hyprland.sh"
  }

  # Install uutils (Rust coreutils)
  provisioner "shell" {
    script = "scripts/install-uutils.sh"
  }

  # Install Ghostty terminal
  provisioner "shell" {
    script = "scripts/install-ghostty.sh"
  }

  # Install and configure zsh
  provisioner "shell" {
    script = "scripts/install-zsh.sh"
  }

  # Final system cleanup and configuration
  provisioner "shell" {
    script = "scripts/cleanup.sh"
  }
}
