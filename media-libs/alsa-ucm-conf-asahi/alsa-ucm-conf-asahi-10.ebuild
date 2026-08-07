# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="ALSA ucm configuration files for Apple silicon devices"
HOMEPAGE="https://alsa-project.org/wiki/Main_Page"
SRC_URI="https://github.com/AsahiLinux/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${PF}.tar.gz"

S="${WORKDIR}/${PN}-${PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~arm64"

RDEPEND=">=media-libs/alsa-lib-1.2.1"
DEPEND="${RDEPEND} media-libs/alsa-ucm-conf"

src_install() {
	insinto /usr/share/alsa
	doins -r ucm2
}
