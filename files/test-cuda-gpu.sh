#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
#
# CUDA and GPU Validation Test Script
# Usage: ./test-cuda-gpu.sh [-v]
#

set -euo pipefail

# Default configuration
VERBOSE=0
EXPECTED_CUDA_VERSION="12.9"
EXPECTED_CUDA_PACKAGE="cuda-toolkit-12-9"
MIN_GPU_MEMORY_MB=1024

# Test counter
PASSED=0

# GPU detection flag
HAS_GPU=0

# Add CUDA to PATH if not already present
if [ -d /usr/local/cuda/bin ] && [[ ":$PATH:" != *":/usr/local/cuda/bin:"* ]]; then
    export PATH="/usr/local/cuda/bin:$PATH"
fi
if [ -d /usr/local/cuda-${EXPECTED_CUDA_VERSION}/bin ] && [[ ":$PATH:" != *":/usr/local/cuda-${EXPECTED_CUDA_VERSION}/bin:"* ]]; then
    export PATH="/usr/local/cuda-${EXPECTED_CUDA_VERSION}/bin:$PATH"
fi

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------

pass() {
    echo "[PASS] $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo "[FAIL] $1"
    exit 1
}

skip() {
    echo "[SKIP] $1"
    exit 77
}

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Test CUDA toolkit and GPU functionality

OPTIONS:
    -v              Verbose mode
    -h              Show this help message

EXAMPLES:
    # Run with default settings
    sudo ./test-cuda-gpu.sh

    # Run with verbose output
    sudo ./test-cuda-gpu.sh -v

EOF
    exit 0
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

verbose_log() {
    if [[ $VERBOSE -eq 1 ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    fi
}

# ------------------------------------------------------------------------------
# Parse Arguments
# ------------------------------------------------------------------------------

while getopts "vh" opt; do
    case $opt in
        v)
            VERBOSE=1
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

# ------------------------------------------------------------------------------
# Test: CUDA Driver Installation
# ------------------------------------------------------------------------------

test_cuda_driver() {
    log "Test: CUDA driver installation..."
    echo ""

    echo "Checking: CUDA installation directory exists"
    if [[ ! -d /usr/local/cuda ]] && ! rpm -q cuda-driver >/dev/null 2>&1; then
        fail "CUDA installation not found at /usr/local/cuda and no cuda-driver package"
    fi
    pass "CUDA installation directory exists"

    if [[ $VERBOSE -eq 1 ]] && [[ -f /usr/local/cuda/version.json ]]; then
        verbose_log "CUDA version info:"
        sed 's/^/  /' /usr/local/cuda/version.json
    fi

    echo ""
}

# ------------------------------------------------------------------------------
# Test: CUDA Toolkit Package
# ------------------------------------------------------------------------------

test_cuda_toolkit_package() {
    log "Test: CUDA toolkit package installation..."
    echo ""

    echo "Checking: ${EXPECTED_CUDA_PACKAGE} package is installed"
    if ! rpm -q "${EXPECTED_CUDA_PACKAGE}" >/dev/null 2>&1; then
        fail "${EXPECTED_CUDA_PACKAGE} package is not installed"
    fi
    pass "${EXPECTED_CUDA_PACKAGE} package is installed"

    verbose_log "Package: $(rpm -q "${EXPECTED_CUDA_PACKAGE}")"

    echo ""
}

# ------------------------------------------------------------------------------
# Test: CUDA Compiler (nvcc)
# ------------------------------------------------------------------------------

test_cuda_compiler() {
    log "Test: CUDA compiler (nvcc)..."
    echo ""

    echo "Checking: nvcc is available in PATH"
    if ! command -v nvcc >/dev/null 2>&1; then
        fail "nvcc not found in PATH"
    fi
    pass "nvcc is available in PATH"

    echo "Checking: nvcc version matches expected CUDA ${EXPECTED_CUDA_VERSION}"
    NVCC_VERSION=$(nvcc --version | grep "release" | awk '{print $5}' | cut -d',' -f1)
    if [[ ! "$NVCC_VERSION" == "$EXPECTED_CUDA_VERSION"* ]]; then
        fail "nvcc version $NVCC_VERSION does not match expected $EXPECTED_CUDA_VERSION"
    fi
    pass "nvcc version is ${NVCC_VERSION}"

    verbose_log "nvcc location: $(command -v nvcc)"
    verbose_log "Full nvcc version:"
    if [[ $VERBOSE -eq 1 ]]; then
        nvcc --version | sed 's/^/  /'
    fi

    echo "Checking: nvcc can compile a simple CUDA program"
    TEMP_DIR=$(mktemp -d)
    cat > "$TEMP_DIR/test.cu" << 'EOF'
#include <stdio.h>
int main() {
    printf("CUDA compiler test\n");
    return 0;
}
EOF

    if ! nvcc "$TEMP_DIR/test.cu" -o "$TEMP_DIR/test_cuda" 2>&1 | tee "$TEMP_DIR/compile.log"; then
        fail "Failed to compile test CUDA program"
    fi
    pass "nvcc can compile a simple CUDA program"

    rm -rf "$TEMP_DIR"

    echo ""
}

# ------------------------------------------------------------------------------
# Test: CUDA Libraries
# ------------------------------------------------------------------------------

test_cuda_libraries() {
    log "Test: CUDA libraries availability..."
    echo ""

    local -a libs=("libcudart.so" "libcublas.so" "libcufft.so" "libcurand.so")
    local found=0

    for lib in "${libs[@]}"; do
        echo "Checking: $lib is in ldconfig cache"
        if ! ldconfig -p | grep -q "$lib"; then
            fail "$lib not found in ldconfig cache"
        fi
        pass "$lib is available"
        found=$((found + 1))
    done

    verbose_log "Found ${found}/${#libs[@]} CUDA libraries"

    echo ""
}

# ------------------------------------------------------------------------------
# Test: GPU Detection
# ------------------------------------------------------------------------------

detect_gpu() {
    log "Detecting GPU hardware..."
    echo ""

    echo "Checking: nvidia-smi is available"
    if ! command -v nvidia-smi >/dev/null 2>&1; then
        fail "nvidia-smi not found in PATH"
    fi
    pass "nvidia-smi is available"

    echo "Checking: GPU hardware presence"
    if sudo nvidia-smi >/dev/null 2>&1; then
        HAS_GPU=1
        GPU_COUNT=$(sudo nvidia-smi -L | wc -l)
        echo "GPU detected: $GPU_COUNT device(s)"

        verbose_log "GPU details:"
        if [[ $VERBOSE -eq 1 ]]; then
            sudo nvidia-smi | sed 's/^/  /'
        fi
    else
        echo "[INFO] nvidia-smi command failed - no GPU hardware detected"
        HAS_GPU=0
    fi

    echo ""
}

# ------------------------------------------------------------------------------
# Test: NVIDIA Driver
# ------------------------------------------------------------------------------

test_nvidia_driver() {
    log "Test: NVIDIA driver..."
    echo ""

    if [[ $HAS_GPU -eq 0 ]]; then
        skip "No GPU hardware detected - cannot test driver"
    fi

    echo "Checking: NVIDIA driver version"
    DRIVER_VERSION=$(sudo nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>&1 | head -n1 || true)
    if [[ -z "$DRIVER_VERSION" ]] || [[ ! "$DRIVER_VERSION" =~ ^[0-9] ]]; then
        fail "Could not determine NVIDIA driver version"
    fi
    pass "NVIDIA driver version: $DRIVER_VERSION"

    echo "Checking: NVIDIA kernel module is loaded"
    # Check lsmod for nvidia modules, or check /proc/driver/nvidia as fallback
    if lsmod | grep -qi nvidia; then
        pass "NVIDIA kernel module is loaded"
        verbose_log "Loaded NVIDIA modules:"
        if [[ $VERBOSE -eq 1 ]]; then
            lsmod | grep -i nvidia | sed 's/^/  /'
        fi
    elif [[ -d /proc/driver/nvidia ]]; then
        pass "NVIDIA driver is loaded (via /proc/driver/nvidia)"
        verbose_log "NVIDIA driver proc entries:"
        if [[ $VERBOSE -eq 1 ]]; then
            find /proc/driver/nvidia/ -maxdepth 1 -printf '%M %u %g %s %p\n' | sed 's/^/  /'
        fi
    else
        fail "NVIDIA kernel module/driver is not loaded"
    fi

    echo ""
}

# ------------------------------------------------------------------------------
# Test: NVIDIA Persistence Daemon
# ------------------------------------------------------------------------------

test_nvidia_persistenced() {
    log "Test: NVIDIA persistence daemon..."
    echo ""

    echo "Checking: nvidia-persistenced service is enabled"
    if ! systemctl is-enabled nvidia-persistenced.service >/dev/null 2>&1; then
        fail "nvidia-persistenced service is not enabled"
    fi
    pass "nvidia-persistenced service is enabled"

    echo "Checking: nvidia-persistenced service is active"
    if ! systemctl is-active nvidia-persistenced.service >/dev/null 2>&1; then
        fail "nvidia-persistenced service is not active"
    fi
    pass "nvidia-persistenced service is active"

    verbose_log "Service status:"
    if [[ $VERBOSE -eq 1 ]]; then
        systemctl status nvidia-persistenced.service --no-pager | sed 's/^/  /'
    fi

    echo ""
}

# ------------------------------------------------------------------------------
# Test: GPU Properties
# ------------------------------------------------------------------------------

test_gpu_properties() {
    log "Test: GPU properties..."
    echo ""

    if [[ $HAS_GPU -eq 0 ]]; then
        skip "No GPU hardware detected - cannot test GPU properties"
    fi

    echo "Checking: GPU count"
    GPU_COUNT=$(sudo nvidia-smi -L | wc -l)
    if [[ $GPU_COUNT -eq 0 ]]; then
        fail "No GPUs detected by nvidia-smi"
    fi
    pass "Detected $GPU_COUNT GPU(s)"

    echo "Checking: GPU compute capability"
    COMPUTE_CAP=$(sudo nvidia-smi --query-gpu=compute_cap --format=csv,noheader 2>&1 | head -n1 || true)
    if [[ -z "$COMPUTE_CAP" ]] || [[ ! "$COMPUTE_CAP" =~ ^[0-9] ]]; then
        fail "Could not determine GPU compute capability"
    fi
    pass "GPU compute capability: $COMPUTE_CAP"

    echo "Checking: GPU memory (minimum ${MIN_GPU_MEMORY_MB} MB)"
    GPU_MEMORY=$(sudo nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>&1 | head -n1 || true)
    if [[ -z "$GPU_MEMORY" ]] || [[ ! "$GPU_MEMORY" =~ ^[0-9]+$ ]]; then
        fail "Could not determine GPU memory"
    fi
    if [[ $GPU_MEMORY -lt $MIN_GPU_MEMORY_MB ]]; then
        fail "GPU memory ($GPU_MEMORY MB) is less than minimum ($MIN_GPU_MEMORY_MB MB)"
    fi
    pass "GPU memory: $GPU_MEMORY MB"

    verbose_log "GPU list:"
    if [[ $VERBOSE -eq 1 ]]; then
        sudo nvidia-smi -L | sed 's/^/  /'
    fi

    echo ""
}

# ------------------------------------------------------------------------------
# Test: CUDA Environment
# ------------------------------------------------------------------------------

test_cuda_environment() {
    log "Test: CUDA environment setup..."
    echo ""

    echo "Checking: CUDA binaries in PATH"
    if ! echo "$PATH" | grep -q "/usr/local/cuda"; then
        fail "CUDA bin directory not in PATH"
    fi
    pass "CUDA binaries are in PATH"

    echo "Checking: CUDA libraries in ldconfig or LD_LIBRARY_PATH"
    if ! echo "${LD_LIBRARY_PATH:-}" | grep -q "/usr/local/cuda" && \
       ! ldconfig -p | grep -q "/usr/local/cuda"; then
        fail "CUDA library directory not found in LD_LIBRARY_PATH or ldconfig"
    fi
    pass "CUDA libraries are configured"

    verbose_log "PATH entries containing cuda:"
    if [[ $VERBOSE -eq 1 ]]; then
        echo "$PATH" | tr ':' '\n' | grep cuda | sed 's/^/  /'
    fi
    if [[ -n "${LD_LIBRARY_PATH:-}" ]]; then
        verbose_log "LD_LIBRARY_PATH entries containing cuda:"
        if [[ $VERBOSE -eq 1 ]]; then
            echo "$LD_LIBRARY_PATH" | tr ':' '\n' | grep cuda | sed 's/^/  /'
        fi
    fi

    echo ""
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

main() {
    log "=========================================================="
    log "CUDA and GPU Validation Test Suite"
    log "=========================================================="
    echo ""

    # Check if this is a GPU-enabled system
    echo "Checking: System has GPU/CUDA components installed"
    if [[ ! -d /usr/local/cuda ]] && ! rpm -q "${EXPECTED_CUDA_PACKAGE}" >/dev/null 2>&1; then
        echo ""
        log "=========================================================="
        skip "No CUDA installation detected - test suite not applicable"
    fi
    echo "CUDA installation detected"
    echo ""

    # CUDA installation tests
    log "=========================================="
    log "CUDA Installation Tests"
    log "=========================================="
    echo ""

    test_cuda_driver
    test_cuda_toolkit_package
    test_cuda_compiler
    test_cuda_libraries
    test_cuda_environment

    # GPU hardware detection
    echo ""
    log "=========================================="
    log "GPU Hardware Detection"
    log "=========================================="
    echo ""

    detect_gpu

    # GPU and driver tests
    if [[ $HAS_GPU -eq 1 ]]; then
        echo ""
        log "=========================================="
        log "GPU and Driver Tests"
        log "=========================================="
        echo ""

        test_nvidia_driver
        test_nvidia_persistenced
        test_gpu_properties
    else
        echo "[INFO] GPU hardware tests skipped - no GPU detected"
    fi

    # If we get here, all tests passed
    echo ""
    log "=========================================================="
    log "All tests passed ($PASSED)"
    log "=========================================================="
    exit 0
}

main "$@"
