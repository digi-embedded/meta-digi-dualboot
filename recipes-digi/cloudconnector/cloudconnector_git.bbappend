# Copyright (C) 2021,2022 Digi International Inc.

FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

DEPENDS += " swupdate"

SRC_URI += " \
    file://0001-cc.conf-pre-set-for-dual-boot-mode.patch \
"
