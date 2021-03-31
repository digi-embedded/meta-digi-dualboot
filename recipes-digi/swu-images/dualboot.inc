# Copyright (C) 2021 Digi International Inc.

# For the eMMC on the true case, and for the NAND on the false case
BOOT_DEV_NAME_A ?= "${@bb.utils.contains('STORAGE_MEDIA', 'mmc', '/dev/mmcblk0p1', 'linux_a', d)}"
BOOT_DEV_NAME_B ?= "${@bb.utils.contains('STORAGE_MEDIA', 'mmc', '/dev/mmcblk0p2', 'linux_b', d)}"
ROOTFS_DEV_NAME_A ?= "${@bb.utils.contains('STORAGE_MEDIA', 'mmc', '/dev/mmcblk0p3', 'rootfs_a', d)}"
ROOTFS_DEV_NAME_B ?= "${@bb.utils.contains('STORAGE_MEDIA', 'mmc', '/dev/mmcblk0p4', 'rootfs_b', d)}"

fill_description() {
        sed -i -e "s,##BOOTIMG_NAME##,${IMG_NAME}-${MACHINE}${BOOTFS_EXT},g" "${WORKDIR}/sw-description"
        sed -i -e "s,##BOOT_DEV_A##,${BOOT_DEV_NAME_A},g" "${WORKDIR}/sw-description"
        sed -i -e "s,##BOOT_DEV_B##,${BOOT_DEV_NAME_B},g" "${WORKDIR}/sw-description"
        sed -i -e "s,##ROOTIMG_NAME##,${IMG_NAME}-${MACHINE}${ROOTFS_EXT},g" "${WORKDIR}/sw-description"
        sed -i -e "s,##ROOTFS_DEV_A##,${ROOTFS_DEV_NAME_A},g" "${WORKDIR}/sw-description"
        sed -i -e "s,##ROOTFS_DEV_B##,${ROOTFS_DEV_NAME_B},g" "${WORKDIR}/sw-description"
        sed -i -e "s,##SW_VERSION##,${SOFTWARE_VERSION},g" "${WORKDIR}/sw-description"
}

