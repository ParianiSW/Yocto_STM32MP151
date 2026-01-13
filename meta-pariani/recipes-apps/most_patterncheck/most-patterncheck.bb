SUMMARY = "MOST PatternCheck utilities (client/server)"
DESCRIPTION = "PatternCheck client/server utilities for MOST, built with upstream NetBeans Makefiles."

LICENSE = "CLOSED"
LIC_FILES_CHKSUM = "file://LICENSE;md5=749c1827ed77687b0bbcdc1802d0f9b0"

SRC_URI = "git://github.com/ParianiSW/most_patterncheck.git;branch=main;protocol=https"
SRCREV = "e7380e76c582687b603f4af20caef0e0e321f0f5"

PV = "1.0+git${SRCPV}"

S = "${WORKDIR}/git"

do_configure[noexec] = "1"

# NON passare CFLAGS/CXXFLAGS/CPPFLAGS: altrimenti sovrascrivi i CFLAGS del Makefile (-c -MMD -MP)
# Usa PROJECT_C_FLAGS, che i Makefile NetBeans includono dentro CFLAGS.
EXTRA_OEMAKE = '\
    CROSS_COMPILE="${TARGET_PREFIX}" \
    CC="${CC}" \
    CXX="${CXX}" \
    PROJECT_C_FLAGS="${CPPFLAGS} ${CFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
'

do_compile() {
    oe_runmake -C ${S}/PatternCheck/Client build
    oe_runmake -C ${S}/PatternCheck/Server build
}

do_install() {
    install -d ${D}${bindir}

    # Artefatti prodotti dai Makefile top-level
    install -m 0755 ${S}/PatternCheck/Client/patternChecker   ${D}${bindir}/most_patterncheck_client
    install -m 0755 ${S}/PatternCheck/Server/patternGenerator ${D}${bindir}/most_patterncheck_server

    # Script helper (opzionali)
    if [ -f ${S}/Client/patternCheck.sh ]; then
        install -m 0755 ${S}/PatternCheck/Client/patternCheck.sh ${D}${bindir}/most_patterncheck_client.sh
    fi
    if [ -f ${S}/Server/generator.sh ]; then
        install -m 0755 ${S}/PatternCheck/Server/generator.sh ${D}${bindir}/most_patterncheck_generator.sh
    fi
}

RDEPENDS:${PN} += "bash"
