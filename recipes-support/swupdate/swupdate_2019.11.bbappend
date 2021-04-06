# Copyright (C) 2021 Digi International Inc.

do_configure_append() {
	# add U-Booot handler to use uboot: type
	echo "CONFIG_BOOTLOADERHANDLER=y" >> ${S}/.config
	cml1_do_configure
}

