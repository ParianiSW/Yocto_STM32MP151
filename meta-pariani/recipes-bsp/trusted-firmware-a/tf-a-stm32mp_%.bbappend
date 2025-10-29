# =========================================================================
#  meta-pariani extension for STM32MP15
# -------------------------------------------------------------------------
#  Enables UART programmer support (STM32MP_UART_PROGRAMMER=1) in TF-A
#  allowing programming via USART (CubeProgrammer serial mode)
#  instead of USB DFU only.
# -------------------------------------------------------------------------
#  Location: meta-pariani/recipes-bsp/trusted-firmware-a/
# =========================================================================

# -------------------------------------------------------------
# Enable STM32MP UART Programmer build option
# -------------------------------------------------------------
#EXTRA_OEMAKE:append = " STM32MP_UART_PROGRAMMER=1 STM32MP_USB_PROGRAMMER=0"
EXTRA_OEMAKE:append = " STM32MP_UART_PROGRAMMER=0 STM32MP_USB_PROGRAMMER=1"


# Optional: explicitly select the USART used for programming
# (default is USART3 on most STM32MP15 boards)
# EXTRA_OEMAKE:append = " STM32MP_UART_PROGRAMMER=1 STM32MP_UART_PROGRAMMER_USART=4"
#EXTRA_OEMAKE:append = " STM32MP_UART_PROGRAMMER_USART=4"

#EXTRA_OEMAKE:remove = " DEBUG=1"

#when set to 1, sets log level to ST_TF_A_LOG_LEVEL_DEBUG (40) else to ST_TF_A_LOG_LEVEL_RELEASE (20)
#EXTRA_OEMAKE:remove = "ST_TF_A_DEBUG_TRACE=1" 
#EXTRA_OEMAKE:remove = "LOG_LEVEL=40"

#set to production
#EXTRA_OEMAKE:append = " ST_TF_A_DEBUG_TRACE=0"
#EXTRA_OEMAKE:append = " LOG_LEVEL=20"

#LOG_LEVEL = "20"
#DEBUG = "1"

#set to debug
EXTRA_OEMAKE:append = " ST_TF_A_DEBUG_TRACE=1"
EXTRA_OEMAKE:append = " LOG_LEVEL=30"

LOG_LEVEL = "30"
DEBUG = "1"

# -------------------------------------------------------------
# Pariani build log (visible in BitBake console output)
# -------------------------------------------------------------
python tfa_log_uart_config() {
    import re

    extra = d.getVar("EXTRA_OEMAKE") or ""

    uart_enabled = bool(re.search("STM32MP_UART_PROGRAMMER=1", extra))
    usb_enabled  = bool(re.search("STM32MP_USB_PROGRAMMER=1", extra))
    match = re.search("STM32MP_UART_PROGRAMMER_USART=(\\d+)", extra)
    usart = match.group(1) if match else "default"

    msg = f"\033[1;32m[meta-pariani]\033[0m TF-A build: EXTRA_OEMAKE={extra})."
    bb.plain(msg)
    
    if uart_enabled:
        msg = f"\033[1;32m[meta-pariani]\033[0m TF-A build: UART programmer ENABLED (USART{usart} boot support active)."
    elif usb_enabled:
        msg = "\033[1;32m[meta-pariani]\033[0m TF-A build: USB DFU programmer ENABLED (UART disabled)."
    else:
        msg = "\033[1;32m[meta-pariani]\033[0m TF-A build: No programmer enabled."

    bb.plain(msg)
}

do_compile[prefuncs] += "tfa_log_uart_config"
