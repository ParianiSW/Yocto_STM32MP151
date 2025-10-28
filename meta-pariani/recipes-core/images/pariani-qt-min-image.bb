SUMMARY = "Pariani STM32MP1 image with Qt5 (Widgets only) on Wayland"
DESCRIPTION = "Customized Weston image for Pariani-MYIR platform"
LICENSE = "Proprietary"

#Note:
#This image replaces st-image-weston as the rootfs in the ST FlashLayout.
#Make sure that FLASHLAYOUT_CONFIG_IMAGE[rootfs] points to this image.

# --- RootFS naming ----------------------------------------------------------
# Optional fallback
IMAGE_NAME_SUFFIX = ".rootfs"

# Include the base ST Weston image recipe as a foundation.
# This allows inheriting all its configuration, features, and package groups.
require recipes-st/images/st-image-weston.bb

# This allows inheriting st partitions image scheme
inherit st-partitions-image

# --- Image feature extensions ----------------------------------------------
# Add or remove features compared to the base image.
# 'debug-tweaks' enables root login over serial/ssh and other dev features.
IMAGE_FEATURES += "\
    debug-tweaks \
    "

# --- Package removals -------------------------------------------------------
# Optionally remove unwanted package groups from the base ST image.
# This helps reduce image size or remove demo apps.
IMAGE_INSTALL:remove = "packagegroup-st-demo"

# Additional Qt packages and configurations are defined
# in the snippet included by the distro configuration
# (meta-pariani/conf/snippets/qt5-minimal-scarthgap.conf)
# (meta-pariani/conf/snippets/...)

# -----------------------------------------------------------------------------
# Build-time information
# -----------------------------------------------------------------------------
python do_image_complete:append() {
    eula = d.getVar("EULA_FILE_ST") or "undefined"
    bb.plain("\033[1;32m[meta-pariani]\033[0m Using local EULA file: %s" % eula)
}

