# Copyright (C) 2021 Digi International

FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

# Add U-boot dual boot support
UBOOT_EXTRA_CONF += " CONFIG_BOOTCOUNT_LIMIT=y \
     CONFIG_BOOTCOUNT_BOOTLIMIT=3 \
     CONFIG_BOOTCOUNT_ENV=y \
     CONFIG_DIGI_DUALBOOT=y \
"

COMPATIBLE_MACHINE = "(ccimx6$)"
