#!/bin/sh
#===============================================================================
#
#  mount_bootparts.sh
#
#  Copyright (C) 2014-2019 by Digi International Inc.
#  All rights reserved.
#
#  This program is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License version 2 as published by
#  the Free Software Foundation.
#
#  !Description: Attempt to mount boot partitions read-only (called from udev)
#
#===============================================================================

BASE_INIT="$(readlink -f "@base_sbindir@/init")"
INIT_SYSTEMD="@systemd_unitdir@/systemd"

if [ "${SUBSYSTEM}" = "block" ]; then
	PARTNAME="${ID_PART_ENTRY_NAME}"
elif [ "${SUBSYSTEM}" = "mtd" ]; then
	MTDN="$(echo ${DEVNAME} | cut -f 3 -d /)"
	PARTNAME="$(grep ${MTDN} /proc/mtd | sed -ne 's,.*"\(.*\)",\1,g;T;p')"
fi

MOUNT_PARAMS="-o silent"
ACTIVE_SYSTEM="$(fw_printenv -n active_system 2>/dev/null)"
# Mount active system partition as read-only
if [ "${PARTNAME}" = "${ACTIVE_SYSTEM}" ]; then
	MOUNT_PARAMS="${MOUNT_PARAMS} -o ro"
fi

if [ "x$BASE_INIT" = "x$INIT_SYSTEMD" ];then
	# systemd as init uses systemd-mount to mount block devices
	MOUNT="/usr/bin/systemd-mount"
	MOUNT_PARAMS="${MOUNT_PARAMS} --no-block"

	if [ -x "$MOUNT" ];
	then
		logger "Using systemd-mount to finish mount"
		BOOT_PART="$(fw_printenv -n mmcpart 2>/dev/null)"
        	BOOT_DEV="$(fw_printenv -n mmcbootdev 2>/dev/null)"

	        CURRENT_PART="$(ls -l /dev/disk/by-partlabel/ | grep -i mmcblk${BOOT_DEV}p${BOOT_PART} | awk '{print $9}')"
	else
		logger "Linux init is using systemd, so please install systemd-mount to finish mount"
		exit 1
	fi
else
	MOUNT="/bin/mount"
	if [ "$(readlink ${MOUNT})" != "/bin/mount.util-linux" ]; then
		if [ "${SUBSYSTEM}" = "block" ]; then
			# Get current boot partition
			BOOT_PART="$(fw_printenv -n mmcpart 2>/dev/null)"
			BOOT_DEV="$(fw_printenv -n mmcbootdev 2>/dev/null)"

			CURRENT_PART="$(ls -l /dev/disk/by-partlabel/ | grep -i mmcblk${BOOT_DEV}p${BOOT_PART} | awk '{print $9}')"
		else
			# Get current boot partition
			PART_INDEX="$(cat /proc/cmdline | awk '{print $3}' | sed -e 's/[ubi.mtd]//g' -e 's/=//')"
			LINUX_INDEX="$(cat /proc/mtd | grep -i ${PARTNAME} | awk '{print $1}' | sed -e 's/[mtd]//g' -e 's/://')"
		fi
		# Busybox mount. Clear default params
		MOUNT_PARAMS=""
		# Mount 'linux_x' partition as read-only
		if [ "${PARTNAME}" = "${ACTIVE_SYSTEM}" ]; then
			MOUNT_PARAMS="${MOUNT_PARAMS} -r"
		fi
	fi
fi

if [ "${SUBSYSTEM}" = "block" ]; then
	# Create mount point if needed
	MOUNTPOINT="/mnt/${PARTNAME}"
	[ -d "${MOUNTPOINT}" ] || mkdir -p ${MOUNTPOINT}

	if [ "${PARTNAME}" = "${CURRENT_PART}" ]; then
		if ! ${MOUNT} -t auto ${MOUNT_PARAMS} ${DEVNAME} ${MOUNTPOINT}; then
			logger -t udev "ERROR: Could not mount ${DEVNAME} under ${MOUNTPOINT}"
			rmdir --ignore-fail-on-non-empty ${MOUNTPOINT}
		fi
	fi
elif [ "${SUBSYSTEM}" = "mtd" ]; then
	# Check if this is the current boot partition and mount it.
	if [ "${PART_INDEX}" = "LINUX_INDEX" ]; then
		# Create mount point if needed
	        MOUNTPOINT="/mnt/${PARTNAME}"
        	[ -d "${MOUNTPOINT}" ] || mkdir -p ${MOUNTPOINT}
		# Before attaching, find out if partition already attached
		MTD_NUM="$(echo ${MTDN} | sed -ne 's,.*mtd\([0-9]\+\),\1,g;T;p')"
		for ubidev in /sys/devices/virtual/ubi/*; do
			echo "${ubidev}" | grep -qs '/sys/devices/virtual/ubi/\*' && continue
			mtd_att="$(cat ${ubidev}/mtd_num)"
			if [ "${mtd_att}" = "${MTD_NUM}" ]; then
				dev_number="$(echo ${ubidev} | sed -ne 's,.*ubi\([0-9]\+\),\1,g;T;p')"
			fi
		done

		# If not already attached, attach and get UBI device number
		if [ -z "${dev_number}" ]; then
			dev_number="$(ubiattach -p ${DEVNAME} 2>/dev/null | sed -ne 's,.*device number \([0-9]\).*,\1,g;T;p' 2>/dev/null)"
		fi
		# Check if volume exists.
		if ubinfo /dev/ubi${dev_number} -N ${PARTNAME} >/dev/null 2>&1; then
			# Mount the volume.
			if ! mount -t ubifs ubi${dev_number}:${PARTNAME} ${MOUNT_PARAMS} ${MOUNTPOINT}; then
				logger -t udev "ERROR: Could not mount '${PARTNAME}' partition"
				rmdir --ignore-fail-on-non-empty ${MOUNTPOINT}
			fi
		else
			logger -t udev "ERROR: Could not mount '${PARTNAME}' partition, volume not found"
			rmdir --ignore-fail-on-non-empty ${MOUNTPOINT}
		fi
	fi
fi
