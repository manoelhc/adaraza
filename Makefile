.PHONY: help init validate build clean run

# Variables
IMAGE_NAME := freebsd-wayland-14.1-aarch64
OUTPUT_DIR := output-freebsd-wayland
PACKER_FILE := freebsd-wayland.pkr.hcl
QEMU_MEMORY := 4096
QEMU_CPUS := 2
QEMU_ARCH := aarch64

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

init: ## Initialize Packer plugins
	@echo "Initializing Packer plugins..."
	packer init $(PACKER_FILE)

validate: ## Validate Packer configuration
	@echo "Validating Packer configuration..."
	packer validate $(PACKER_FILE)

build: init validate ## Build the FreeBSD image
	@echo "Building FreeBSD Wayland image..."
	packer build $(PACKER_FILE)

build-headless: init validate ## Build the image in headless mode
	@echo "Building FreeBSD Wayland image (headless)..."
	packer build -var 'headless=true' $(PACKER_FILE)

clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	rm -rf $(OUTPUT_DIR)
	rm -rf packer_cache
	rm -f packer-manifest.json
	rm -f crash.log

run: ## Run the built image with QEMU (ARM64 for Raspberry Pi)
	@if [ ! -f "$(OUTPUT_DIR)/$(IMAGE_NAME)" ]; then \
		echo "Error: Image not found. Run 'make build' first."; \
		exit 1; \
	fi
	@echo "Starting QEMU ARM64 with the built image (Raspberry Pi emulation)..."
	qemu-system-$(QEMU_ARCH) \
		-M virt \
		-cpu cortex-a72 \
		-m $(QEMU_MEMORY) \
		-smp $(QEMU_CPUS) \
		-drive file=$(OUTPUT_DIR)/$(IMAGE_NAME),format=qcow2,if=virtio \
		-bios /usr/share/qemu-efi-aarch64/QEMU_EFI.fd \
		-device virtio-gpu-pci \
		-device usb-ehci \
		-device usb-kbd \
		-device usb-mouse \
		-netdev user,id=net0,hostfwd=tcp::2222-:22 \
		-device virtio-net-pci,netdev=net0 \
		-display gtk,gl=on

run-vnc: ## Run the built image with VNC (no graphical environment needed)
	@if [ ! -f "$(OUTPUT_DIR)/$(IMAGE_NAME)" ]; then \
		echo "Error: Image not found. Run 'make build' first."; \
		exit 1; \
	fi
	@echo "Starting QEMU ARM64 with VNC on port 5900..."
	@echo "Connect with: vncviewer localhost:5900"
	qemu-system-$(QEMU_ARCH) \
		-M virt \
		-cpu cortex-a72 \
		-m $(QEMU_MEMORY) \
		-smp $(QEMU_CPUS) \
		-drive file=$(OUTPUT_DIR)/$(IMAGE_NAME),format=qcow2,if=virtio \
		-bios /usr/share/qemu-efi-aarch64/QEMU_EFI.fd \
		-device virtio-gpu-pci \
		-netdev user,id=net0,hostfwd=tcp::2222-:22 \
		-device virtio-net-pci,netdev=net0 \
		-vnc :0

check-deps: ## Check if required dependencies are installed
	@echo "Checking dependencies..."
	@command -v packer >/dev/null 2>&1 || { echo "Error: packer is not installed"; exit 1; }
	@command -v qemu-system-$(QEMU_ARCH) >/dev/null 2>&1 || { echo "Error: qemu-system-$(QEMU_ARCH) is not installed"; exit 1; }
	@test -f /usr/share/qemu-efi-aarch64/QEMU_EFI.fd || { echo "Warning: QEMU EFI firmware not found at /usr/share/qemu-efi-aarch64/QEMU_EFI.fd"; echo "Install qemu-efi-aarch64 package or adjust path"; }
	@echo "All dependencies are installed!"

info: ## Show information about the image
	@if [ -f "$(OUTPUT_DIR)/$(IMAGE_NAME)" ]; then \
		echo "Image: $(OUTPUT_DIR)/$(IMAGE_NAME)"; \
		qemu-img info $(OUTPUT_DIR)/$(IMAGE_NAME); \
	else \
		echo "Error: Image not found. Run 'make build' first."; \
	fi
