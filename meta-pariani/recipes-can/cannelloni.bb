SUMMARY = "CAN bus tunneling over UDP"
DESCRIPTION = "Cannelloni tunnels SocketCAN frames over UDP networks."

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=751419260aa954499f7abaabaa882bbe"

SRC_URI = "git://github.com/ParianiSW/cannelloni.git;branch=master;protocol=https"
SRCREV = "5a6a6a715abc42212d98c89ac2f0edffd8b79db6"

PV = "1.2+git${SRCPV}"

inherit cmake pkgconfig

DEPENDS += "libconfig"

EXTRA_OECMAKE += "\
    -DSCTP_SUPPORT=OFF \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_CXX_FLAGS=-Wno-error \
"

