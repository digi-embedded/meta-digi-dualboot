#
# Copyright (C) 2021 Digi International.
#

FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

PACKAGE_ARCH = "${MACHINE_ARCH}"

RDEPENDS_${PN} += " dualboot-init"
