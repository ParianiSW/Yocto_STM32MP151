#!/usr/bin/env bash
# ============================================================================
#  Pariani Yocto Build Cleanup Script (Extended)
# ----------------------------------------------------------------------------
#  Safely cleans Yocto build directories without removing downloads/
#  or shared sstate-cache, with optional deep clean (--sstate).
#
#  Usage:
#    ./clean-pariani-build.sh [build_dir] [--sstate]
#
#  Defaults:
#    build_dir = build-pariani-st-stm32mp1-myir
# ============================================================================
set -e

# ----------------------------------------------------------------------------
# Colors
# ----------------------------------------------------------------------------
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

# ----------------------------------------------------------------------------
# Prevent sourcing
# ----------------------------------------------------------------------------
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    echo -e "\033[1;31m[ERROR]\033[0m This script must not be sourced."
    echo "Please run it directly: ./clean-pariani-build.sh [options]"
    kill -INT $$
fi

# ----------------------------------------------------------------------------
# Detect project root (directory containing "layers/")
# ----------------------------------------------------------------------------
ROOTOE=$PWD
while [ ! -d "${ROOTOE}/layers" ] && [ "${ROOTOE}" != "/" ]; do
    ROOTOE=$(dirname "${ROOTOE}")
done

if [ ! -d "${ROOTOE}/layers" ]; then
    echo -e "${RED}[ERROR]${NC} Could not locate Yocto project root (no 'layers/' found)."
    exit 1
fi
# ----------------------------------------------------------------------------
# Defaults
# ----------------------------------------------------------------------------
DEFAULT_BUILD_DIR="build-pariani-st-stm32mp151-myir-cls"

BUILD_DIR_INPUT="$1"
EXTRA_OPTION="$2"

# ----------------------------------------------------------------------------
# Allow out of order arguments
# ----------------------------------------------------------------------------
if [[ "$1" == "--sstate" ]]; then
    EXTRA_OPTION="--sstate"
    BUILD_DIR_INPUT=""
elif [[ "$2" == "--sstate" ]]; then
    EXTRA_OPTION="--sstate"
fi

# ----------------------------------------------------------------------------
# Help Option
# ----------------------------------------------------------------------------
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo -e "${GREEN}==============================================================${NC}"
    echo -e "${GREEN}        Pariani Yocto Build Cleanup Utility${NC}"
    echo -e "${GREEN}==============================================================${NC}"
    echo ""
    echo "Usage:"
    echo "  ./clean-pariani-build.sh [build_dir] [--sstate]"
    echo ""
    echo "Options:"
    echo "  --help, -h     Show this help message and exit"
    echo "  --sstate       Perform deep clean using BitBake:"
    echo "                 bitbake -k -c cleansstate world"
    echo ""
    echo "Defaults:"
    echo "  build_dir = ${DEFAULT_BUILD_DIR}"
    echo ""
    echo "Examples:"
    echo "  ./clean-pariani-build.sh"
    echo "  ./clean-pariani-build.sh build-test-stm32mp1"
    echo "  ./clean-pariani-build.sh --sstate"
    echo ""
    exit 0
fi

# ----------------------------------------------------------------------------
# Determine build directory
# ----------------------------------------------------------------------------
BUILD_DIR="${BUILD_DIR_INPUT:-$DEFAULT_BUILD_DIR}"
BUILD_PATH="${ROOTOE}/${BUILD_DIR}"

# ----------------------------------------------------------------------------
# Verify directory exists
# ----------------------------------------------------------------------------
if [ ! -d "${BUILD_PATH}" ]; then
    echo -e "${RED}[ERROR]${NC} Build directory not found: ${BUILD_PATH}"
    echo "Available build directories:"
    find "${ROOTOE}" -maxdepth 1 -type d -name "build-*" | sed 's|.*/|- |'
    exit 1
fi

# ----------------------------------------------------------------------------
# Banner
# ----------------------------------------------------------------------------
echo -e "${GREEN}==============================================================${NC}"
echo -e "${GREEN}   Pariani Yocto Build Cleanup Utility${NC}"
echo -e "${GREEN}==============================================================${NC}"
echo -e "${YELLOW}Target build:${NC} ${BUILD_DIR}"
echo -e "${YELLOW}Location    :${NC} ${BUILD_PATH}"
echo -e "${YELLOW}Preserve    :${NC} downloads/ and sstate-cache/"
if [[ "$EXTRA_OPTION" == "--sstate" ]]; then
    echo -e "${YELLOW}Extra clean :${NC} bitbake -k -c cleansstate world"
fi
echo -e "${GREEN}--------------------------------------------------------------${NC}"

# ----------------------------------------------------------------------------
# Confirmation
# ----------------------------------------------------------------------------
read -r -p "Proceed with cleanup of ${BUILD_DIR}? [y/N]: " confirm
if [[ ! "$confirm" =~ ^[yY]$ ]]; then
    echo "Aborted."
    exit 0
fi

cd "${BUILD_PATH}"

# ----------------------------------------------------------------------------
# Optional deep clean (BitBake-managed)
# ----------------------------------------------------------------------------
if [[ "$EXTRA_OPTION" == "--sstate" ]]; then
    echo ""
    echo -e "${YELLOW}[INFO] Performing deep clean: bitbake -k -c cleansstate world${NC}"
    echo -e "This may take several minutes..."
    echo ""
    # Ensure bitbake command exists
    if ! command -v bitbake >/dev/null 2>&1; then
        echo -e "${RED}[ERROR] bitbake not found in PATH.${NC}"
        echo "Please source your build environment first (e.g. setup-pariani-env.sh)."
        exit 1
    fi

    # Run clean sstate before removing tmp
    bitbake -k -c cleansstate world || \
        echo -e "${YELLOW}[WARNING]${NC} Some tasks failed during cleansstate."
fi

# ----------------------------------------------------------------------------
# File cleanup
# ----------------------------------------------------------------------------
echo ""
echo -e "${GREEN}Cleaning build directory files...${NC}"

if [ -d tmp-glibc ]; then
    echo "  - Removing tmp-glibc"
    rm -rf tmp-glibc
fi
if [ -d tmp ]; then
    echo "  - Removing tmp"
    rm -rf tmp
fi
if [ -d cache ]; then
    echo "  - Removing cache"
    rm -rf cache
fi
if [ -d buildhistory ]; then
    echo "  - Removing buildhistory"
    rm -rf buildhistory
fi
if [ -f bitbake-cookerdaemon.log ]; then
    echo "  - Removing bitbake-cookerdaemon.log"
    rm -f bitbake-cookerdaemon.log
fi

# Keep shared data
[ -d downloads ] && echo "  - Keeping downloads/"
[ -d sstate-cache ] && echo "  - Keeping sstate-cache/"

# ----------------------------------------------------------------------------
# Done
# ----------------------------------------------------------------------------
echo ""
echo -e "${GREEN}Cleanup complete.${NC}"
if [[ "$EXTRA_OPTION" == "--sstate" ]]; then
    echo -e "${GREEN}(includes BitBake cleansstate world)${NC}"
fi
echo ""
echo -e "Done"
echo ""
