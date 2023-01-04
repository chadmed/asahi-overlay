# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="ALSA ucm configuration files for Apple silicon devices"
HOMEPAGE="https://alsa-project.org/wiki/Main_Page"
MY_COMMIT="141ba65ce31fcf9412829e47bb3a2f8c0d46b78c"
SRC_URI="https://github.com/povik/${PN}/archive/${MY_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
LICENSE="BSD"
SLOT="0"

KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~loong ~m68k ~mips ppc ppc64 ~riscv sparc x86"
IUSE=""

RDEPEND="!<media-libs/alsa-lib-1.2.1"
DEPEND="${RDEPEND} media-libs/alsa-ucm-conf"

src_unpack() {
	unpack ${PN}-${PV}.tar.gz || die "Could not unpack the archive"
	mv ${PN}-${MY_COMMIT} ${PN}-${PV} || die "Could not move source tree"
}

src_install() {
	insinto /usr/share/alsa
	doins -r ucm2
}
