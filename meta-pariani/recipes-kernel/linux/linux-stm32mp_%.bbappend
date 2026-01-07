# =========================================================================
#  meta-pariani extension for STM32MP15
# -------------------------------------------------------------------------
#  Kernel configuration override for Pariani STM32MP151 platforms.
#
#  This bbappend replaces the vendor defconfig with a Pariani-maintained
#  defconfig, enabling:
#   - USB Type-C core support
#   - TCPM (Type-C Port Manager)
#   - TCPCI (Type-C Port Controller Interface)
#   - ....WIP....
#
#  Target HW:
#   - STM32MP151
#   - PTN5110N Type-C Port Controller (I2C)
#
#  Location:
#   meta-pariani/recipes-kernel/linux/linux-stm32mp_%.bbappend
#
#  NOTE:
#   KCONFIG_MODE = "replace" is intentionally used to guarantee deterministic
#   kernel configuration across BSP updates.
# =========================================================================


# -------------------------------------------------------------
# Kernel defconfig override
# -------------------------------------------------------------
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
KERNEL_CONFIG_FRAGMENTS:append = " ${WORKDIR}/fragment-80-usb.config \
  ${WORKDIR}/fragment-81-typec.config \
  ${WORKDIR}/fragment-82-nosound.config \
  ${WORKDIR}/fragment-83-norf.config \
  ${WORKDIR}/fragment-90-most.config"

SRC_URI += "file://fragment-80-usb.config"
SRC_URI += "file://fragment-81-typec.config"
SRC_URI += "file://fragment-82-nosound.config"
SRC_URI += "file://fragment-83-norf.config"
SRC_URI += "file://fragment-90-most.config"


# -------------------------------------------------------------
# Pariani kernel configuration banner
# -------------------------------------------------------------
python pariani_kernel_config_banner() {
    pn = d.getVar("PN") or "unknown"
    frags = d.getVar("KERNEL_CONFIG_FRAGMENTS") or "none"
    bb.plain("\033[1;34m[meta-pariani]\033[0m Applying Pariani kernel configuration fragments")
    bb.plain(f"\033[1;34m[meta-pariani]\033[0m Kernel recipe        : {pn}")
    bb.plain(f"\033[1;34m[meta-pariani]\033[0m KERNEL_CONFIG_FRAGMENTS          : {frags}")
}


do_configure[prefuncs] += "pariani_kernel_config_banner"
