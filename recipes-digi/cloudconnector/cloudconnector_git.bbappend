# Copyright (C) 2021, Digi International Inc.

FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

DEPENDS += " swupdate"

SRC_URI += " \
    file://0001-cc.conf-pre-set-for-dual-boot-mode.patch \
    file://0002-library-add-swupdate-static-API-library.patch \
    file://0003-firmware_update-add-on-the-fly-support.patch \
"
