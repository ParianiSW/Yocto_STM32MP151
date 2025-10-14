SUMMARY = "Pariani STM32MP1 image with Qt5 (Widgets only) on Wayland"
DESCRIPTION = "Customized Weston image for Pariani-MYIR platform"
LICENSE = "Proprietary"


# Include the base ST Weston image recipe as a foundation.
# This allows inheriting all its configuration, features, and package groups.
require recipes-st/images/st-image-weston.bb

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
