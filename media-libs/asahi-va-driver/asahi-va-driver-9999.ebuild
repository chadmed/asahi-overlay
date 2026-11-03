# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="A VA-API (libva) backend driver for video decoders on Apple silicon systems"
HOMEPAGE="https://github.com/AsahiLinux/asahi-va-driver"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/AsahiLinux/${PN}.git"
	inherit git-r3
else
	SRC_URI="https://github.com/AsahiLinux/${PN}/archive/refs/tags/${PV}/${PN}-${PV}.tar.gz"
	KEYWORDS="~arm64"
fi


S="${WORKDIR}/${PN}-${PV}"

LICENSE="GPL-3"
SLOT="0"

DEPEND="media-libs/libva"
RDEPEND="${DEPEND}"
BDEPEND=""

src_unpack() {
	if [[ ${PV} == 9999 ]]; then
		git-r3_src_unpack
	else
		unpack ${P}.tar.gz
	fi
}

pkg_postinst() {
	einfo "asahi-va-driver will be autoselected on systems with asahi GPU driver"
	einfo "On systems without GPU driver (M3 devices in November 2026) the driver"
	einfo "has to be manually selected with the environment variable"
	einfo "\"LIBVA_DRIVER_NAME\"."
	einfo
	einfo "Hardware decoding in firefox will only work if the following is set:"
	einfo "    export MOZ_DISABLE_RDD_SANDBOX=1"
	einfo "Note that disabling the RDD sandbox trades away some of the protection"
	einfo "Firefox normally applies to media decoding."
	einfo
}
