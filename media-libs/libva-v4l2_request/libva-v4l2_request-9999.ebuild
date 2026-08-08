# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="A VA-API (libva) backend driver for V4L2 stateless video decoders"
HOMEPAGE="https://xff.cz/git/libva-v4l2_request"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/sofus13/libva-v4l2_request.git"
	inherit git-r3
else
	SRC_URI="https://github.com/sofus13/${PN}/archive/refs/tags/${PV}.tar.gz -> ${PF}.tar.gz"
	KEYWORDS="~arm64"
fi


S="${WORKDIR}/${PN}-${PV}"

LICENSE="GPL-3.0-or-later"
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
	einfo "Hardware decoding in firefox will only work if the following is set:"
	einfo "    export MOZ_DISABLE_RDD_SANDBOX=1"
	einfo "Note that disabling the RDD sandbox trades away some of the protection"
	einfo "Firefox normally applies to media decoding."
	einfo
}
