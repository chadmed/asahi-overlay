# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
PYTHON_COMPAT=( python3_{10..14} )

# $PV is expected to be of following form: 2023.07_p2
MY_TAG="$(ver_cut 4)"
MY_P="asahi-v$(ver_cut 1-2)-${MY_TAG}"

DESCRIPTION="Asahi Linux fork of Das U-Boot"
HOMEPAGE="https://asahilinux.org/"
SRC_URI="https://github.com/AsahiLinux/u-boot/archive/refs/tags/${MY_P}.tar.gz -> ${PN}-${PV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~arm64"

PATCHES=(
)

BDEPEND="
	app-arch/cpio
	dev-lang/perl
	sys-devel/bc
	sys-devel/bison
	sys-devel/flex
	dev-build/make
	>=sys-libs/ncurses-5.2
	virtual/libelf
	virtual/pkgconfig
	sys-apps/dtc
	dev-vcs/git"

RDEPEND="${BDEPEND}
	sys-apps/asahi-scripts"

src_unpack() {
	unpack ${PN}-${PV}.tar.gz
	mv u-boot-${MY_P} ${PN}-${PV}
}

src_configure() {
	emake apple_m1_defconfig
}

src_compile() {
	cd "${S}" || die
	emake
}

src_install() {
	dodir /usr/lib/asahi-boot
	cp "${S}"/u-boot-nodtb.bin "${ED}"/usr/lib/asahi-boot/u-boot-nodtb.bin || die
}

pkg_postinst() {
	elog "U-Boot has been installed to /usr/lib/asahi-boot/u-boot-nodtb.bin."
	elog "You must run update-m1n1 for the new version to be installed"
	elog "in the ESP."
	elog "Please see the Asahi Linux Wiki for more information."
}

pkg_postrm() {
	elog "U-Boot has been removed from /usr/lib/asahi-boot/ but has not"
	elog "been removed from the ESP. You need to do this manually, though"
	elog "you really shouldn't."
}
