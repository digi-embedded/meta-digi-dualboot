# Copyright (C) 2021 Digi International

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
    file://altboot.txt \
"

do_deploy_append() {
	# Alternate boot script for dual boot
	mkimage -T script -n "Alternate bootscript" -C none -d ${WORKDIR}/altboot.txt ${DEPLOYDIR}/altboot.scr

	# Sign the script
	if [ "${TRUSTFENCE_SIGN}" = "1" ]; then
		export CONFIG_SIGN_KEYS_PATH="${TRUSTFENCE_SIGN_KEYS_PATH}"
		[ -n "${TRUSTFENCE_KEY_INDEX}" ] && export CONFIG_KEY_INDEX="${TRUSTFENCE_KEY_INDEX}"
		[ -n "${TRUSTFENCE_DEK_PATH}" ] && [ "${TRUSTFENCE_DEK_PATH}" != "0" ] && export CONFIG_DEK_PATH="${TRUSTFENCE_DEK_PATH}"
		[ -n "${TRUSTFENCE_SIGN_MODE}" ] && export CONFIG_SIGN_MODE="${TRUSTFENCE_SIGN_MODE}"

		# Sign boot script
		TMP_SIGNED_BOOTSCR="$(mktemp ${WORKDIR}/altboot-signed.scr)"
		trustfence-sign-artifact.sh -p "${DIGI_FAMILY}" -b "${DEPLOYDIR}/altboot.scr" "${TMP_SIGNED_BOOTSCR}"
		mv "${TMP_SIGNED_BOOTSCR}" "${DEPLOYDIR}/altboot.scr"
	fi
}
