SUMMARY = "Unicens for INIC network with MQTT extension"
DESCRIPTION = "Unicens for INIC network with MQTT extension libmosquitto."

LICENSE = "CLOSED"
LIC_FILES_CHKSUM = "file://LICENSE;md5=749c1827ed77687b0bbcdc1802d0f9b0"

SRC_URI = "git://github.com/ParianiSW/unicensd-mqtt.git;branch=main;protocol=https"
SRC_URI[sha256sum] = "b00a7526085a690fe3375c405e09f867de44c073fcb093afd7d9e647c8feaab5"
SRCREV = "e4a7a163c6428aec1a87e0a7facc4a3f1104b79c"

PV = "1.0+git${SRCPV}"

inherit cmake pkgconfig

DEPENDS += "mosquitto"

S = "${WORKDIR}/git"

EXTRA_OECMAKE = "-DNO_RAW_CLOCK=OFF"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/unicensc ${D}${bindir}/unicensc
}
