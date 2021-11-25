# Copyright (C) 2021 Digi International

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
    file://altboot.txt \
"

do_deploy_append() {
	# Alternate boot script for dual boot
	mkimage -T script -n "Alternate bootscript" -C none -d ${WORKDIR}/altboot.txt ${DEPLOYDIR}/altboot.scr
}
