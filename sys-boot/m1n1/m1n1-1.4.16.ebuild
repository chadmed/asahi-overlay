# Copyright 2022 James Calligeros <jcalligeros99@gmail.com>
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="Apple Silicon bootloader and experimentation playground"
HOMEPAGE="https://asahilinux.org/"
SRC_URI="https://github.com/AsahiLinux/m1n1/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="arm64"
IUSE="clang"

BDEPEND="dev-build/make"

RDEPEND="
	sys-boot/u-boot
	|| (
		sys-kernel/asahi-sources
		sys-kernel/asahi-kernel
	   )
"

BDEPEND="${BDEPEND}
	clang? ( sys-devel/clang )
"

src_compile() {
	cd "${S}" || die
	if use clang; then
		emake USE_CLANG=1 \
		RELEASE=1 \
		ARCH="${CHOST}"
	else
		emake USE_CLANG=0 \
		RELEASE=1 \
		ARCH="${CHOST}-"
	fi
}

src_install() {
	dodir /usr/lib/asahi-boot
	cp "${S}"/build/m1n1.bin "${ED}"/usr/lib/asahi-boot/m1n1.bin || die
}

pkg_postinst() {
	elog "m1n1 has been installed at /usr/lib/asahi-boot/m1n1.bin"
	elog "You must run update-m1n1 for the new version to be installed"
	elog "in the ESP."
	elog "Please see the Asahi Linux Wiki for more information."
}

pkg_postrm() {
	elog "m1n1 has been removed from /usr/lib/asahi-boot/ but has not"
	elog "been removed from the ESP. You need to do this manually, though"
	elog "you really shouldn't."
}
