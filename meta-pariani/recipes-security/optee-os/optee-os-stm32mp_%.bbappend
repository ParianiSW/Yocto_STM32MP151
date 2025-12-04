# =============================================================================
#  meta-pariani extension for OP-TEE OS (STM32MP1)
# -----------------------------------------------------------------------------
#  Purpose  : Reduce verbosity and memory footprint by lowering log level
#  Context  : Used with Scarthgap (Yocto 6.x, ST release v6.6)
#  Location : meta-pariani/recipes-security/optee-os/optee-os-stm32mp_%.bbappend
# =============================================================================

# -----------------------------------------------------------------------------
# OP-TEE LOG LEVEL reference:
#   0 -> None (silent, release mode)
#   1 -> Error only
#   2 -> Info (default ST)
#   3 -> Debug
#   4 -> Verbose (trace everything)
# -----------------------------------------------------------------------------

# Enable build-time trace variable to inject log settings
ST_OPTEE_DEBUG_TRACE = "1"              
ST_OPTEE_DEBUG_LOG_LEVEL = "2"           
ST_OPTEE_CORE_DEBUG:forcevariable = "y"
ST_OPTEE_CORE_DEBUG_INFO:forcevariable = "y"

# Append these flags to EXTRA_OEMAKE so they override defaults
EXTRA_OEMAKE:append = " CFG_TEE_CORE_LOG_LEVEL=${ST_OPTEE_DEBUG_LOG_LEVEL} CFG_TEE_CORE_DEBUG=${ST_OPTEE_CORE_DEBUG} CFG_TEE_CORE_DEBUG_INFO=${ST_OPTEE_CORE_DEBUG_INFO}"

##################################################################

# Optional: explicitly mark build as release
#EXTRA_OEMAKE:append = " CFG_TEE_CORE_DEBUG_INFO=n CFG_UNWIND=n NOWERROR=1"


# -----------------------------------------------------------------------------
# Pariani build log banner (console message)
# -----------------------------------------------------------------------------
python optee_log_banner() {
    import re
    extra = d.getVar("EXTRA_OEMAKE") or ""
    msg = f"\033[1;32m[meta-pariani]\033[0m OP-TEE build: EXTRA_OEMAKE={extra})."
    bb.plain(msg)
}

do_compile[prefuncs] += "optee_log_banner"

