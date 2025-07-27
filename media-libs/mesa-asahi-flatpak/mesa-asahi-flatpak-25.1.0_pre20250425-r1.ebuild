# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rpm

DESCRIPTION="Asahi OpenGL Extension for Flatpak"
HOMEPAGE="https://asahilinux.org https://flatpak.org"

FEDORA_MAJOR="42"

SRC_URI="
https://download.copr.fedorainfracloud.org/results/@asahi/flatpak/fedora-${FEDORA_MAJOR}-aarch64/08985462-mesa-asahi-23.08-flatpak/mesa-asahi-23.08-flatpak-$(ver_cut 1-3)~asahipre$(ver_cut 5)-1.aarch64.rpm -> ${P}-2308.rpm
"

S="${WORKDIR}"

LICENSE="MIT SGI-B-2.0"
SLOT="0"

KEYWORDS="arm64"

RDEPEND="
	sys-apps/flatpak
	>=media-libs/mesa-25.1.0
"

DEPEND="${RDEPEND}
"
BDEPEND="
	app-arch/rpm2targz
"

src_unpack() {
	mkdir "${WORKDIR}/${P}-2308" || die
	cd "${WORKDIR}/${P}-2308" || die
	rpm_unpack ${P}-2308.rpm
}

src_prepare() {
	default
}

src_install() {
	insinto /
	doins -r "${WORKDIR}/${P}-2308/var/"
}
