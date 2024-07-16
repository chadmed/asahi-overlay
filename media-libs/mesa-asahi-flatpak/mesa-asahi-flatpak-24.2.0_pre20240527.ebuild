# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 18 )

inherit rpm

DESCRIPTION="Asahi OpenGL Extension for Flatpak"
HOMEPAGE="https://asahilinux.org https://flatpak.org"

SRC_URI="
https://download.copr.fedorainfracloud.org/results/@asahi/flatpak/fedora-rawhide-aarch64/07734912-mesa-asahi-23.08-flatpak/mesa-asahi-23.08-flatpak-24.2.0~asahipre20240527-1.aarch64.rpm -> ${PN}-2308.rpm
https://download.copr.fedorainfracloud.org/results/@asahi/flatpak/fedora-rawhide-aarch64/07734915-mesa-asahi-22.08-flatpak/mesa-asahi-22.08-flatpak-24.2.0~asahipre20240527-1.aarch64.rpm -> ${PN}-2208.rpm
"

S="${WORKDIR}"

LICENSE="MIT SGI-B-2.0"
SLOT="0"

KEYWORDS="~arm64"

IUSE="+2208 +2308"

RDEPEND="
	sys-apps/flatpak
"

DEPEND="${RDEPEND}
"
BDEPEND="
	app-arch/rpm2targz
"

src_unpack() {
	use 2308 && (
		mkdir "${WORKDIR}/${PN}-2308" || die
		cd "${WORKDIR}/${PN}-2308" || die
		rpm_unpack ${PN}-2308.rpm
	)

	use 2208 && (
		mkdir "${WORKDIR}/${PN}-2208" || die
		cd "${WORKDIR}/${PN}-2208" || die
		rpm_unpack ${PN}-2208.rpm
	)

	cd "${WORKDIR}" || die
}

src_prepare() {
	default
}

mesa-asahi-flatpak_install() {
	local ver="${1}"
	newenvd \
		"${WORKDIR}/${PN}-${ver}/usr/lib/environment.d/50-asahi-flatpak-extension-${ver:0:2}.${ver:2:3}.conf" \
		"50asahi-flatpak-extension-${ver:0:2}.${ver:2:3}"

	insinto /
	doins -r "${WORKDIR}/${PN}-${ver}/var/"
}

src_install() {
	use 2308 && mesa-asahi-flatpak_install "2308"
	use 2208 && mesa-asahi-flatpak_install "2208"
}
