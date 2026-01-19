SUMMARY = "Unicens for INIC network with MQTT extension"
DESCRIPTION = "Unicens for INIC network with MQTT extension libmosquitto."

LICENSE = "CLOSED"
LIC_FILES_CHKSUM = "file://LICENSE;md5=749c1827ed77687b0bbcdc1802d0f9b0"

SRC_URI = "git://github.com/ParianiSW/unicensd-mqtt.git;branch=main;protocol=https"
SRCREV = "e4a7a163c6428aec1a87e0a7facc4a3f1104b79c"

PV = "1.0+git${SRCPV}"

inherit cmake pkgconfig

DEPENDS += "mosquitto"

S = "${WORKDIR}/git"

EXTRA_OECMAKE += "-DNO_RAW_CLOCK=OFF"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/unicensc ${D}${bindir}/unicensc
    install -m 0755 ${B}/unicensd ${D}${bindir}/unicensd
}

PACKAGES += "${PN}-client"

FILES:${PN} = "${bindir}/unicensd"
FILES:${PN}-client = "${bindir}/unicensc"
