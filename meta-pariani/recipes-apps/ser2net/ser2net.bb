SUMMARY = "Serial to network proxy daemon"
DESCRIPTION = "ser2net allows access to serial ports over TCP/IP."

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

SRC_URI = "git://github.com/ParianiSW/ser2net.git;branch=master;protocol=https"
SRCREV = "9ec8bdb849a8d7a4711925161f1a612823f88335"

PV = "4.6+git${SRCPV}"

inherit autotools pkgconfig systemd

DEPENDS += "gensio libyaml"

S = "${WORKDIR}/git"

#SYSTEMD_SERVICE:${PN} = "ser2net.service"
#SYSTEMD_AUTO_ENABLE:${PN} = "disable"

do_install:append() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${S}/ser2net.yaml \
        ${D}${sysconfdir}/ser2net.yaml
}


do_install:append() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${S}/ser2net.yaml \
        ${D}${sysconfdir}/ser2net.yaml
}

FILES:${PN} += "${sysconfdir}/ser2net.yaml"
#if modified by the user, avoid overwrite from .deb
CONFFILES:${PN} += "${sysconfdir}/ser2net/ser2net.yaml"
