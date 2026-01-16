.PHONY: help init validate build clean run

# Variables
IMAGE_NAME := freebsd-wayland-14.1
OUTPUT_DIR := output-freebsd-wayland
PACKER_FILE := freebsd-wayland.pkr.hcl
QEMU_MEMORY := 4096
QEMU_CPUS := 2

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

run: ## Run the built image with QEMU
	@if [ ! -f "$(OUTPUT_DIR)/$(IMAGE_NAME)" ]; then \
		echo "Error: Image not found. Run 'make build' first."; \
		exit 1; \
	fi
	@echo "Starting QEMU with the built image..."
	qemu-system-x86_64 \
		-enable-kvm \
		-m $(QEMU_MEMORY) \
		-smp $(QEMU_CPUS) \
		-drive file=$(OUTPUT_DIR)/$(IMAGE_NAME),format=qcow2 \
		-display gtk,gl=on \
		-vga virtio \
		-net nic,model=virtio \
		-net user,hostfwd=tcp::2222-:22

run-vnc: ## Run the built image with VNC (no graphical environment needed)
	@if [ ! -f "$(OUTPUT_DIR)/$(IMAGE_NAME)" ]; then \
		echo "Error: Image not found. Run 'make build' first."; \
		exit 1; \
	fi
	@echo "Starting QEMU with VNC on port 5900..."
	@echo "Connect with: vncviewer localhost:5900"
	qemu-system-x86_64 \
		-enable-kvm \
		-m $(QEMU_MEMORY) \
		-smp $(QEMU_CPUS) \
		-drive file=$(OUTPUT_DIR)/$(IMAGE_NAME),format=qcow2 \
		-vnc :0 \
		-vga virtio \
		-net nic,model=virtio \
		-net user,hostfwd=tcp::2222-:22

check-deps: ## Check if required dependencies are installed
	@echo "Checking dependencies..."
	@command -v packer >/dev/null 2>&1 || { echo "Error: packer is not installed"; exit 1; }
	@command -v qemu-system-x86_64 >/dev/null 2>&1 || { echo "Error: qemu is not installed"; exit 1; }
	@echo "All dependencies are installed!"

info: ## Show information about the image
	@if [ -f "$(OUTPUT_DIR)/$(IMAGE_NAME)" ]; then \
		echo "Image: $(OUTPUT_DIR)/$(IMAGE_NAME)"; \
		qemu-img info $(OUTPUT_DIR)/$(IMAGE_NAME); \
	else \
		echo "Error: Image not found. Run 'make build' first."; \
	fi
