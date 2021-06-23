# Copyright (C) 2021 Digi International Inc.

FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

SRC_URI += " \
    file://0001-Makefile-change-Makefile-to-build-swupdate-library-s.patch \
"

do_configure_append() {
	# add U-Booot handler to use uboot: type
	echo "CONFIG_BOOTLOADERHANDLER=y" >> ${B}/.config
	cml1_do_configure
}

