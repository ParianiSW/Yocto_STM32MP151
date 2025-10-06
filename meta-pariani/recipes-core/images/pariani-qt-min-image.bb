SUMMARY = "Pariani STM32MP1 image with Qt5 (Widgets only) on Wayland"
LICENSE = "MIT"

inherit core-image

# Enable SSH access via Dropbear
IMAGE_FEATURES += "ssh-server-dropbear"

# Additional Qt packages and configurations are defined
# in the snippet included by the distro configuration
# (meta-pariani/conf/snippets/qt5-minimal-scarthgap.conf)
