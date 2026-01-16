#!/bin/sh
set -e

echo "==> Installing uutils (Rust coreutils)"

# Check if uutils is available in ports
if pkg search uutils-coreutils | grep -q uutils-coreutils; then
    echo "==> Installing uutils from ports"
    pkg install -y uutils-coreutils
else
    echo "==> Building uutils from source"
    
    # Install Rust if not already installed
    if ! command -v cargo > /dev/null 2>&1; then
        pkg install -y rust
    fi
    
    # Clone uutils repository
    cd /tmp
    git clone https://github.com/uutils/coreutils.git uutils
    cd uutils
    
    # Build uutils
    cargo build --release --features unix
    
    # Install uutils binaries
    mkdir -p /usr/local/bin/uutils
    cp target/release/coreutils /usr/local/bin/uutils/
    
    # Create symlinks for individual utilities
    cd /usr/local/bin/uutils
    for util in base32 base64 basename cat chmod chown cp cut date dd df dirname \
                echo env expand expr false fold head id join link ln ls mkdir \
                mktemp mv nl od paste printenv printf pwd readlink realpath rm \
                rmdir seq sha1sum sha224sum sha256sum sha384sum sha512sum sleep \
                sort split sum sync tail tee test touch tr true truncate uname \
                uniq unlink wc whoami yes; do
        ./coreutils link $util
    done
    
    # Add to PATH (optional - users can choose to use uutils or BSD coreutils)
    echo 'export PATH="/usr/local/bin/uutils:$PATH"' >> /etc/profile
    
    # Cleanup
    cd /
    rm -rf /tmp/uutils
fi

echo "==> uutils installed successfully"
echo "==> Note: uutils commands are available in /usr/local/bin/uutils"
