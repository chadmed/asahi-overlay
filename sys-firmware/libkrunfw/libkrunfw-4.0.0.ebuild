# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Linux kernel shared object for libkrun"
HOMEPAGE="https://github.com/containers/libkrunfw"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="arm64"
IUSE="asahi"

MY_KVER="6.4.7"

BDEPEND="
	dev-python/pyelftools
	asahi? ( app-alternatives/gzip )
"

SRC_URI="
	https://github.com/containers/libkrunfw/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${MY_KVER}.tar.xz
"

PATCHES=(
	"${FILESDIR}/patch-makefile.patch"
)

src_unpack() {
	default
	mv "${WORKDIR}/linux-${MY_KVER}" "${S}/."
}

src_prepare() {
	default
	use asahi && (
		eapply "${FILESDIR}/use-asahi-config.patch"
		zcat "${FILESDIR}/libkrunfw-config.gz" > "${S}/linux-${MY_KVER}/.config"
	)
}

src_compile() {
	# WAR: Makefile finds aarch64, kernel expects arm64
	emake KARCH=arm64 all|| die "Could not build libkrunfw kernel!"
}

src_install() {
	emake PREFIX="${D}/usr/" install || die "Failed to install kernel library!"
}
