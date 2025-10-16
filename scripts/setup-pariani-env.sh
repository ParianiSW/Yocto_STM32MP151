#!/usr/bin/env bash
# ============================================================================
#  Pariani Yocto Environment Setup Script
# ----------------------------------------------------------------------------
#  Sets up the build environment for Pariani STM32MP1 platforms,
#  based on ST OpenSTLinux (Yocto Scarthgap).
# ============================================================================
#set -e

# ----------------------------------------------------------------------------
# Colors
# ----------------------------------------------------------------------------
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
BLUE='\033[1;34m'
NC='\033[0m' # No color

# ----------------------------------------------------------------------------
# Must be sourced, not executed
# ----------------------------------------------------------------------------
if [[ "$0" == "$BASH_SOURCE" ]]; then
    echo -e "${RED}[ERROR]${NC} This script must be *sourced*, not executed."
    echo -e "Usage: ${YELLOW}source setup-pariani-env.sh [options]${NC}"
    return 1 2>/dev/null || exit 1
fi

# ----------------------------------------------------------------------------
# Root user check
# ----------------------------------------------------------------------------
if [ "$(whoami)" = "root" ]; then
    echo -e "${RED}[ERROR]${NC} Do not run as root."
    return 1
fi

# ----------------------------------------------------------------------------
# Parse options
# ----------------------------------------------------------------------------
RESET=0
DISTRO_ARG=""
MACHINE_ARG=""

for arg in "$@"; do
    case "$arg" in
        --help|-h)
            echo -e "${GREEN}==============================================================${NC}"
            echo -e "${GREEN}   Pariani Yocto Environment Setup Script${NC}"
            echo -e "${GREEN}==============================================================${NC}"
            echo ""
            echo "Usage:"
            echo "  source setup-pariani-env.sh [DISTRO] [MACHINE] [--reset]"
            echo ""
            echo "Options:"
            echo "  --help, -h   Show this help message and exit"
            echo "  --reset      Reset existing build/conf before setup"
            echo ""
            echo "Defaults:"
            echo "  DISTRO  = pariani-st"
            echo "  MACHINE = stm32mp151-myir-cls"
            echo ""
            echo "Examples:"
            echo "  source setup-pariani-env.sh"
            echo "  source setup-pariani-env.sh pariani-st stm32mp1-ev1"
            echo "  source setup-pariani-env.sh --reset"
            echo ""
            return 0
            ;;
        --reset)
            RESET=1
            ;;
        *)
            if [ -z "$DISTRO_ARG" ]; then
                DISTRO_ARG="$arg"
            elif [ -z "$MACHINE_ARG" ]; then
                MACHINE_ARG="$arg"
            fi
            ;;
    esac
done

# ----------------------------------------------------------------------------
# Project paths
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Detect project root (directory containing "layers/")
# ----------------------------------------------------------------------------
ROOTOE=$PWD
while [ ! -d "${ROOTOE}/layers" ] && [ "${ROOTOE}" != "/" ]; do
    ROOTOE=$(dirname "${ROOTOE}")
done

if [ ! -d "${ROOTOE}/layers" ]; then
    echo -e "${RED}[ERROR]${NC} Could not locate Yocto project root (no 'layers/' found)."
    return 1
fi

# ----------------------------------------------------------------------------
# Determine build system root
# ----------------------------------------------------------------------------
if [ -d "${ROOTOE}/layers/poky" ]; then
    OECORE_PATH="${ROOTOE}/layers/poky"
elif [ -d "${ROOTOE}/layers/openembedded-core" ]; then
    OECORE_PATH="${ROOTOE}/layers/openembedded-core"
else
    echo -e "${RED}[ERROR]${NC} Neither poky nor openembedded-core found under layers/."
    return 1
fi

PARIANI_LAYER="${ROOTOE}/layers/Yocto_STM32MP151/meta-pariani"
TEMPLATECONF="${PARIANI_LAYER}/conf/templates/default"

# ----------------------------------------------------------------------------
# Defaults
# ----------------------------------------------------------------------------
DISTRO=${DISTRO_ARG:-pariani-st}
MACHINE=${MACHINE_ARG:-stm32mp151-myir-cls}
BUILD_DIR="${ROOTOE}/build-${DISTRO}-${MACHINE}"

# ----------------------------------------------------------------------------
# Check host distro (non-bloccante)
# ----------------------------------------------------------------------------
if [ -f /etc/lsb-release ]; then
    source /etc/lsb-release
    case "$DISTRIB_ID" in
        Ubuntu)
            if ! [[ " 20.04 22.04 24.04 " =~ " ${DISTRIB_RELEASE} " ]]; then
                echo -e "${YELLOW}[WARNING]${NC} Ubuntu ${DISTRIB_RELEASE} not officially validated."
            fi
            ;;
        *)
            echo -e "${YELLOW}[WARNING]${NC} Host distro not Ubuntu – untested environment."
            ;;
    esac
else
    echo -e "${YELLOW}[WARNING]${NC} Unable to detect host distro (missing /etc/lsb-release)."
fi

# ----------------------------------------------------------------------------
# Sanity checks
# ----------------------------------------------------------------------------
if [ ! -d "${OECORE_PATH}" ]; then
    echo -e "${RED}[ERROR]${NC} Missing openembedded-core/poky at ${OECORE_PATH}"
    return 1
fi

if [ ! -d "${PARIANI_LAYER}" ]; then
    echo -e "${RED}[ERROR]${NC} Missing meta-pariani layer at ${PARIANI_LAYER}"
    return 1
fi

if [ ! -f "${OECORE_PATH}/oe-init-build-env" ]; then
    echo -e "${RED}[ERROR]${NC} Missing oe-init-build-env in ${OECORE_PATH}."
    return 1
fi

# ----------------------------------------------------------------------------
# Display banner
# ----------------------------------------------------------------------------
echo -e "${GREEN}==============================================================${NC}"
echo -e "${GREEN}     Pariani Yocto Build Environment Setup${NC}"
echo -e "${GREEN}==============================================================${NC}"
echo -e "${YELLOW}ROOTOE :${NC}  ${ROOTOE}"
echo -e "${YELLOW}oecore  :${NC} ${OECORE_PATH}"
echo -e "${YELLOW}Distro  :${NC} ${DISTRO}"
echo -e "${YELLOW}Machine :${NC} ${MACHINE}"
echo -e "${YELLOW}Build   :${NC} ${BUILD_DIR}"
echo -e "${YELLOW}Template:${NC} ${TEMPLATECONF}"
echo -e "${GREEN}--------------------------------------------------------------${NC}"

# ----------------------------------------------------------------------------
# Reset build configuration if requested
# ----------------------------------------------------------------------------
if [ "$RESET" -eq 1 ] && [ -d "${BUILD_DIR}/conf" ]; then
    echo -e "${BLUE}[INFO]${NC} Resetting configuration in ${BUILD_DIR}/conf ..."
    rm -rf "${BUILD_DIR}/conf"
fi

# ----------------------------------------------------------------------------
# Initialize environment
# ----------------------------------------------------------------------------
echo -e "${BLUE}[INFO]${NC} Initializing OpenEmbedded environment ..."
mkdir -p "${BUILD_DIR}"
export TEMPLATECONF DISTRO MACHINE
source "${OECORE_PATH}/oe-init-build-env" "${BUILD_DIR}"

# ----------------------------------------------------------------------------
# Auto-create minimal conf if missing - redoundant check!
# ----------------------------------------------------------------------------
echo -e "${BLUE}[INFO]${NC} Auto-creating minimal conf if missing ..."
CONF_DIR="${BUILD_DIR}/conf"

if [ ! -f "${CONF_DIR}/local.conf" ]; then
    echo -e "${BLUE}[INFO]${NC} Creating new local.conf ..."
    mkdir -p "${CONF_DIR}"
    cp "${TEMPLATECONF}/local.conf.sample" "${CONF_DIR}/local.conf" 2>/dev/null
fi

if [ ! -f "${CONF_DIR}/bblayers.conf" ]; then
    echo -e "${BLUE}[INFO]${NC} Creating new bblayers.conf ..."
    mkdir -p "${CONF_DIR}"
    cp "${TEMPLATECONF}/bblayers.conf.sample" "${CONF_DIR}/bblayers.conf" 2>/dev/null
fi

# ----------------------------------------------------------------------------
# Summary
# ----------------------------------------------------------------------------
echo ""
echo -e "${GREEN}Environment initialized successfully.${NC}"
echo -e " Build directory : ${BUILD_DIR}"
echo -e " Distro          : ${DISTRO}"
echo -e " Machine         : ${MACHINE}"
echo ""
echo -e "To build your image, run:"
echo -e "  ${YELLOW}bitbake pariani-qt-min-image${NC}   # main Pariani image"
echo -e "  ${YELLOW}bitbake st-image-weston${NC}       # base ST image"
echo ""
echo -e "To reset configuration, rerun with:"
echo -e "  ${YELLOW}source setup-pariani-env.sh --reset${NC}"
echo ""
