#!/bin/sh
#===============================================================================
#
#  update-firmware-dual.sh
#
#  Copyright (C) 2021 by Digi International Inc.
#  All rights reserved.
#
#  This program is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License version 2 as published by
#  the Free Software Foundation.
#
#
#  !Description: Dual boot firmware update script
#
#===============================================================================

SCRIPTNAME="$(basename $(readlink -f ${0}))"
VERBOSE=""

## Local functions
usage() {
	cat <<EOF

Usage: ${SCRIPTNAME} [OPTIONS] </your-path/your-filename>.swu

    -v               Enable verbosity
    -h               Show this help

EOF
}

while :; do
	case $1 in
		-v|--verbose) VERBOSE="-v"
		;;
		-h|--help) usage;exit
		;;
		*) UPDATE_FILE="${1}"
		    break
		;;
	esac
	shift
done

# Check update file parameter.
if [ -z "${UPDATE_FILE}" ]; then
	echo "[ERROR] Update file not specified"
	exit
fi

PARTTABLE="/proc/mtd"
MTDINDEX="$(sed -ne "s/\(^mtd[0-9]\+\):.*\<environment\>.*/\1/g;T;p" ${PARTTABLE} 2>/dev/null)"

if [ -z "${MTDINDEX}" ]; then
	# Get Boot partition device and index.
	BOOT_PART="$(fw_printenv -n mmcpart 2>/dev/null)"
	BOOT_DEV="$(fw_printenv -n mmcbootdev 2>/dev/null)"

	CURRENT_PART="$(ls -l /dev/disk/by-partlabel/ | grep -i mmcblk${BOOT_DEV}p${BOOT_PART} | awk '{print $9}')"

	# Get current partition information so we can
	# determine where to flash the images.
	if [ "${CURRENT_PART}" = "linux_a" ]; then
		echo "Current system is A; Updating system on B"
		KERNELBOOT="linux_b"
		ROOTFS="rootfs_b"
		IMAGE_SET="mmc,secondary"
	else
		echo "Current system is B; Updating system on A"
		KERNELBOOT="linux_a"
		ROOTFS="rootfs_a"
		IMAGE_SET="mmc,primary"
	fi

	# get boot partition index
	MMC_PART="$(ls -l /dev/disk/by-partlabel/ | grep -i ${KERNELBOOT} | awk '{print $11}' | sed -e 's/[../mmcblkp]//g' -e 's/^.//')"

	# search rootfs UUID
	MMCROOT_PART="$(ls -l /dev/disk/by-partlabel/ | grep -i ${ROOTFS} | awk '{print $11}' | sed -e 's/[../mmcblkp]//g' -e 's/^.//')"
	PART_UUID="$(ls -l /dev/disk/by-partuuid/ | grep -i mmcblk${BOOT_DEV}p${MMCROOT_PART} | awk '{print $9}')"

	echo ""
	echo "Updating '${IMAGE_SET}' image set from '${UPDATE_FILE}'..."
	echo ""

	# Execute the update.
	swupdate ${VERBOSE} -i "${UPDATE_FILE}" -e "${IMAGE_SET}"
	if [ "$?" = "0" ]; then
		fw_setenv mmcroot PARTUUID=${PART_UUID}
		fw_setenv mmcpart ${MMC_PART}
		fw_setenv active_system ${KERNELBOOT}
		echo "Firmware update finished; Rebooting system."
		reboot -f
	else
		echo "[ERROR] $? There was an error performing the update"
	fi
else
	# Get Boot partition device and index.
	MTD_BOOT_PART="$(fw_printenv -n mtdbootpart 2>/dev/null)"

	# Get current partition information so we can
	# determine where to flash the images.
	if [ "${MTD_BOOT_PART}" = "linux_a" ]; then
		echo "Current system is A; Updating system on B"
		KERNELBOOT="linux_b"
		ROOTFS="rootfs_b"
		IMAGE_SET="mtd,secondary"
	else
		echo "Current system is B; Updating system on A"
		KERNELBOOT="linux_a"
		ROOTFS="rootfs_a"
		IMAGE_SET="mtd,primary"
	fi

	# get boot partition index
	LINUX_INDEX="$(cat /proc/mtd | grep -i ${KERNELBOOT} | awk '{print $1}' | sed -e 's/[mtd]//g' -e 's/://')"

	# get rootfs index
	ROOTFS_INDEX="$(cat /proc/mtd | grep -i ${ROOTFS} | awk '{print $1}' | sed -e 's/[mtd]//g' -e 's/://')"

	echo ""
	echo "Updating '${IMAGE_SET}' image set from '${UPDATE_FILE}'..."
	echo ""

	# Execute the update.
	swupdate ${VERBOSE} -i "${UPDATE_FILE}" -e "${IMAGE_SET}"
	if [ "$?" = "0" ]; then
		fw_setenv mtdlinuxindex ${LINUX_INDEX}
		fw_setenv mtdrootfsindex ${ROTFS_INDEX}
		fw_setenv mtdbootpart ${KERNELBOOT}
		fw_setenv active_system ${KERNELBOOT}
		echo "Firmware update finished; Rebooting system."
		reboot -f
	else
		echo "[ERROR] $? There was an error performing the update"
	fi
fi
