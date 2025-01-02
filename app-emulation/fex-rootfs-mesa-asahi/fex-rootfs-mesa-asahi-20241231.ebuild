# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd linux-info

DESCRIPTION="FEX rootfs overlay containing asahi mesa"
HOMEPAGE="https://github.com/WhatAmISupposedToPutHere/fex-rootfs"

SRC_URI="
	https://github.com/WhatAmISupposedToPutHere/fex-rootfs/releases/download/mesa-${PV}/fex-mesa.sqfs -> ${P}.sqfs
	https://github.com/WhatAmISupposedToPutHere/fex-rootfs/archive/refs/tags/20241114.tar.gz -> ${P}.tar.gz
"

S="${WORKDIR}/fex-rootfs-20241114"

LICENSE="metapackage MIT"
SLOT="0"
KEYWORDS="-* ~arm64"
DEPEND="
	systemd? ( sys-apps/systemd )
"
RDEPEND="
	${DEPEND}
	app-emulation/fex-rootfs-gentoo
"
IUSE="systemd"

pkg_pretend() {
	CONFIG_CHECK="~SQUASHFS ~SQUASHFS_ZSTD"
	check_extra_config
}

src_install() {
	local base="/usr/share/fex-emu-rootfs-layers/gentoo"
	insinto "${base}/images/"
	newins "${DISTDIR}/${P}.sqfs" 30-mesa.sqfs
	systemd_dounit 'systemd/usr-share-fex\x2demu\x2drootfs\x2dlayers-gentoo-layers-30\x2dmesa.mount'
}

pkg_prerm() {
	[[ "${MERGE_TYPE}" == "buildonly" || "$(systemd_is_booted)" == 0 ]] && return
	systemctl daemon-reload
	systemctl stop 'usr-share-fex\x2demu\x2drootfs\x2dlayers-gentoo-layers-30\x2dmesa.mount'
}

pkg_postrm() {
	[[ "$(systemd_is_booted)" == 0 ]] && return
	rmdir "${EROOT}/usr/share/fex-emu-rootfs-layers/gentoo/layers/30-mesa/" 2>/dev/zero
	systemctl daemon-reload
	systemctl start 'usr-share-fex\x2demu-RootFS-Gentoo.mount'
}

pkg_postinst() {
	[[ "${MERGE_TYPE}" == "buildonly" || "$(systemd_is_booted)" == 0 ]] && return
	systemctl daemon-reload
	systemctl restart 'usr-share-fex\x2demu-RootFS-Gentoo.mount'
}
