# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd linux-info

DESCRIPTION="A x86 system image used for FEX"
HOMEPAGE="https://github.com/WhatAmISupposedToPutHere/fex-rootfs"

SRC_URI="
	https://github.com/WhatAmISupposedToPutHere/fex-rootfs/releases/download/${PV}/fex-rootfs.sqfs -> ${P}-root.sqfs
	https://github.com/WhatAmISupposedToPutHere/fex-rootfs/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
"

S="${WORKDIR}/fex-rootfs-${PV}"

LICENSE="metapackage MIT"
SLOT="0"
KEYWORDS="-* ~arm64"
RDEPEND="
	gnome-extra/zenity
	sys-apps/xdg-desktop-portal
	systemd? ( sys-apps/systemd )
	!app-emulation/fex-rootfs-mesa-asahi
"
DEPEND="${RDEPEND}"
IUSE="systemd"

pkg_pretend() {
	CONFIG_CHECK="~SQUASHFS ~SQUASHFS_ZSTD"
	check_extra_config
	[[ "${MERGE_TYPE}" != "buildonly" && "$(systemd_is_booted)" == 0 ]] || return
	ewarn "This package depends on systemd being the init system for correct operation"
	ewarn "On non-systemd systems assembling all the mount points correctly is left"
	ewarn "as an excercise for the user."
}

src_install() {
	local base="/usr/share/fex-emu-rootfs-layers/gentoo"
	insinto "${base}/images/"
	newins "${DISTDIR}/${P}-root.sqfs" 00-base.sqfs
	keepdir "${base}/work/"
	keepdir "${base}/writable/"
	gen_dir="$(systemd_get_systemgeneratordir)"
	exeinto "${gen_dir#"${EPREFIX}"}"
	doexe systemd/fex-gentoo-rootfs-generator
	systemd_dounit 'systemd/usr-share-fex\x2demu\x2drootfs\x2dlayers-gentoo-layers-00\x2dbase.mount'
}

pkg_prerm() {
	[[ "${MERGE_TYPE}" == "buildonly" || "$(systemd_is_booted)" == 0 ]] && return
	systemctl daemon-reload
	systemctl stop 'usr-share-fex\x2demu\x2drootfs\x2dlayers-gentoo-layers-00\x2dbase.mount'
}

pkg_postinst() {
	[[ "${MERGE_TYPE}" == "buildonly" || "$(systemd_is_booted)" == 0 ]] && return
	systemctl daemon-reload
	systemctl start 'usr-share-fex\x2demu-RootFS-Gentoo.mount'
}
