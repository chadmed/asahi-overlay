# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="Apple Silicon bootloader and experimentation playground"
HOMEPAGE="https://asahilinux.org/"
SRC_URI="
	https://github.com/AsahiLinux/m1n1/releases/download/v${PV}/m1n1-stage2-v${PV}.zip -> ${PN}-${PV}.zip
"
S="${WORKDIR}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~arm64"

BDEPEND="
	app-arch/unzip
"

RDEPEND="
	sys-boot/u-boot
	|| (
		sys-kernel/asahi-sources
		virtual/dist-kernel:asahi
	   )
	!sys-boot/m1n1
"

src_compile() {
	true
}

src_install() {
	insinto /usr/lib/asahi-boot
	doins m1n1.bin
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
