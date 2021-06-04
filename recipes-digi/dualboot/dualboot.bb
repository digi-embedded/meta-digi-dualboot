# Copyright (C) 2021 Digi International Inc.

SUMMARY = "Digi Embedded Yocto Dual boot support"
SECTION = "base"
LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = " \
    file://dualboot-init \
    file://firmware-update-dual.sh \
    file://firmware-update-check.service \
"

S = "${WORKDIR}"

inherit systemd update-rc.d

do_install() {
	install -d ${D}${sysconfdir}/init.d/
	install -m 0755 ${WORKDIR}/dualboot-init ${D}${sysconfdir}/dualboot-init
	ln -sf /etc/dualboot-init ${D}${sysconfdir}/init.d/dualboot-init

	install -d ${D}${bindir}
	install -m 0755 ${WORKDIR}/firmware-update-dual.sh ${D}${bindir}

	install -d ${D}${systemd_unitdir}/system/
	install -m 0644 ${WORKDIR}/firmware-update-check.service ${D}${systemd_unitdir}/system/
}

PACKAGES =+ "${PN}-init"
FILES_${PN}-init = " \
    ${sysconfdir}/dualboot-init \
    ${sysconfdir}/init.d/dualboot-init \
    ${bindir}/firmware-update-dual.sh \
    ${systemd_unitdir}/system/firmware-update-check.service \
"

INITSCRIPT_PACKAGES += "${PN}-init"
INITSCRIPT_NAME_${PN}-init = "dualboot-init"
INITSCRIPT_PARAMS_${PN}-init = "start 19 2 3 4 5 . stop 21 0 1 6 ."

SYSTEMD_PACKAGES = "${PN}-init"
SYSTEMD_SERVICE_${PN}-init = "firmware-update-check.service"

PACKAGE_ARCH = "${MACHINE_ARCH}"

# Add swupdate into the rootfs for dual boot support
RDEPENDS_${PN}-init = " \
    swupdate \
"

