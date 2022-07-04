# Copyright 2022 James Calligeros <jcalligeros99@gmail.com>
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
ETYPE="sources"
PYTHON_COMPAT=( python3_{8..10} )

inherit eutils autotools

DESCRIPTION="Asahi Linux kernel sources"
HOMEPAGE="https://asahilinux.org/"
LICENSE="GPL-2"
IUSE="symlink"
KEYWORDS="arm64 ~arm64"
SLOT="0"
SRC_URI="https://github.com/AsahiLinux/linux/archive/refs/tags/asahi-5.18-7.tar.gz -> ${P}.tar.gz"

RDEPEND="
	app-arch/cpio
	dev-lang/perl
	sys-devel/bc
	sys-devel/bison
	sys-devel/flex
	sys-devel/make
	sys-apps/dtc
	>=sys-libs/ncurses-5.2
	virtual/libelf
	virtual/pkgconfig"


src_unpack() {
	if [[ ${PV} == "9999" ]]; then
		einfo "Using GitHub sources, cloning from AsahiLinux/linux..."
		git-r3_src_unpack
	else
		if [[ -n ${A} ]]; then
			unpack ${A}
		fi
	fi
}

src_compile() {
	cd "${S}" || die
}

src_install() {
	dodir /usr/src
	mv ${S} "${ED%/}"/usr/src || die
	use symlink && ln -snf /usr/src/${P} /usr/src/linux
}


pkg_postinst() {
	elog "From here, follow the standard Gentoo Handbook instructions for"
	elog "building a kernel."
	elog " "
	elog "For proper firmware support, see the Asahi Linux wiki."
}

pkg_postrm() {
	elog "Follow the standard kernel removal/upgrade procedure"
}
