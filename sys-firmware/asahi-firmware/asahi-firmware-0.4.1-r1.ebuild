# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1

_name=asahi-installer

DESCRIPTION="Asahi FW extraction script"
HOMEPAGE="https://asahilinux.org"
SRC_URI="https://github.com/AsahiLinux/${_name}/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="arm64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/${_name}-${PV}"

src_install() {
	distutils-r1_src_install

	dosbin ${FILESDIR}/asahi-fwextract

	# install for now a simple rc script into /etc/local.d
	exeinto /etc/local.d/
	doexe ${FILESDIR}/asahi-firmware.start
}

pkg_postinst() {
	elog "Asahi vendor firmware update script"
	elog "Please run 'asahi-fwextract' after each update of this package."

	if [ -e ${ROOT}/bin/update-vendor-fw -o -e ${ROOT}/etc/local.d/apple-firmware.start ]; then
		ewarn "please remober to remove '/bin/update-vendor-fw' and"
		ewarn "'/etc/local.d/apple-firmware.start'"
	fi
}
