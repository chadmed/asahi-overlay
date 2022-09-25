# Copyright 2022 James Calligeros <jcalligeros99@gmail.com>
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python3_{8..10} )

inherit eutils autotools toolchain-funcs

DESCRIPTION="Apple Silicon support scripts"
HOMEPAGE="https://asahilinux.org/"
LICENSE="MIT"
SLOT="0"
KEYWORDS="arm64"

PATCHES=("${FILESDIR}/update-m1n1-dtbs.patch"
         "${FILESDIR}/update-m1n1-installdir.patch")

BDEPEND="
    sys-devel/make"

inherit distutils-r1

SRC_URI="https://github.com/AsahiLinux/${PN}/archive/refs/tags/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"

src_prepare() {
        default
}

src_compile() {
        emake || die "Could not invoke emake"
}

src_install() {
        default
}

pkg_postinst() {
        if [ ! -e ${ROOT}/usr/lib/asahi-boot ]; then
                ewarn "These scripts are intended for use on Apple Silicon"
                ewarn "machines with the Asahi tooling installed! Please"
                ewarn "install sys-boot/m1n1, sys-boot/u-boot and"
                ewarn "sys-firmware/asahi-firmware!"
        fi
	elog "Asahi scripts have been installed to /usr/local. For more"
	elog "information on how to use them, please visit the Wiki."
	if [ -e ${ROOT}/bin/update-m1n1 ]; then
		ewarn "You need to remove /bin/update-m1n1."
	fi
}
