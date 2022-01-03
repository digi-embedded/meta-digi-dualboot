# Copyright (C) 2021 Digi International Inc.

FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

SRC_URI += " \
    file://0001-Makefile-change-Makefile-to-build-swupdate-library-s.patch \
    file://0002-config-add-on-the-fly-build-configuration-variable.patch \
    ${@oe.utils.conditional('TRUSTFENCE_SIGN', '1', 'file://trustfence.conf', '', d)} \
"

do_configure_append() {
	# add U-Booot handler to use uboot: type
	echo "CONFIG_BOOTLOADERHANDLER=y" >> ${B}/.config
	echo "CONFIG_DIGI_ON_THE_FLY=y" >> ${B}/.config
	cml1_do_configure
}

do_install_append() {
	# If Trustfence is enabled, launch swupdate with support to use the public key,
	# in order to verify swupdate packages.
	if [ "${TRUSTFENCE_SIGN}" = "1" ]; then
		# Install configuration file.
		install -d ${D}${libdir}/
		install -m 0755 ${WORKDIR}/trustfence.conf ${D}${libdir}/swupdate/conf.d/
	fi
}

FILES_${PN} += " \
    ${@oe.utils.conditional('TRUSTFENCE_SIGN', '1', '${libdir}/swupdate/conf.d/trustfence.conf', '', d)} \
"
