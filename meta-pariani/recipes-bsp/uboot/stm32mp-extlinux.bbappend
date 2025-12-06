FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://extlinux.conf"

python pariani_extlinux_log_banner() {
    msg = "\033[1;32m[meta-pariani]\033[0m stm32mp-extlinux: installing custom extlinux.conf (override root=...)."
    bb.plain(msg)
}

# esegui il banner prima di do_install
do_install[prefuncs] += "pariani_extlinux_log_banner"

do_install:append() {
    # Sovrascrivi l'extlinux.conf generato automaticamente
    install -m 0644 ${WORKDIR}/extlinux.conf ${D}/boot/extlinux/extlinux.conf
}
