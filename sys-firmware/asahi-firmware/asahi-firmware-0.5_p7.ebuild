# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1

_name=asahi-installer
MY_P="0.5pre7"

DESCRIPTION="Asahi FW extraction script"
HOMEPAGE="https://asahilinux.org"
SRC_URI="https://github.com/AsahiLinux/${_name}/archive/refs/tags/v${MY_P}.tar.gz -> ${PN}-${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~arm64"

DEPEND="sys-apps/asahi-scripts"
RDEPEND="${DEPEND}
	app-arch/lzfse"
BDEPEND=""

S="${WORKDIR}/${_name}-${MY_P}"

src_install() {
	distutils-r1_src_install

	dosbin ${FILESDIR}/asahi-fwextract

}

pkg_postinst() {
	elog "Asahi vendor firmware update script"
	elog "Please run 'asahi-fwextract' after each update of this package."

	if [ -e ${ROOT}/bin/update-vendor-fw -o -e ${ROOT}/etc/local.d/apple-firmware.start ]; then
		ewarn "Please remember to remove '/{s}bin/update-vendor-fw' and"
		ewarn "'/etc/local.d/apple-firmware.start'"
	fi

	if [ -e ${ROOT}/etc/local.d/asahi-firmware.start ]; then
		ewarn "Please remove /etc/local.d/asahi-firmware.start as it is"
		ewarn "obsolete and no longer required."
	fi

	if [ -e ${ROOT}/sbin/update-vendor-firmware ]; then
		ewarn "Please remove /sbin/update-vendor-firmware"
	fi
}