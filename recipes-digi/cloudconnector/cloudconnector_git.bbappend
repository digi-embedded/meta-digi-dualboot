# Copyright (C) 2021, Digi International Inc.

FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

SRC_URI += " \
    file://0001-cc.conf-pre-set-for-dual-boot-mode.patch \
"
