# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 18 )

inherit rpm

DESCRIPTION="Asahi OpenGL Extension for Flatpak"
HOMEPAGE="https://asahilinux.org https://flatpak.org"

SRC_URI="
2308? (
	https://download.copr.fedorainfracloud.org/results/@asahi/flatpak/fedora-40-aarch64/07799255-mesa-asahi-23.08-flatpak/mesa-asahi-23.08-flatpak-24.2.0~asahipre20240727-1.aarch64.rpm  -> ${P}-2308.rpm
)

2208? (
	https://download.copr.fedorainfracloud.org/results/@asahi/flatpak/fedora-40-aarch64/07799256-mesa-asahi-22.08-flatpak/mesa-asahi-22.08-flatpak-24.2.0~asahipre20240727-1.aarch64.rpm -> ${P}-2208.rpm
)
"

S="${WORKDIR}"

LICENSE="MIT SGI-B-2.0"
SLOT="0"

KEYWORDS="~arm64"

IUSE="+2208 +2308"
REQUIRED_USE="|| ( 2208 2308 )"

RDEPEND="
	sys-apps/flatpak
	=media-libs/mesa-${PV}
"

DEPEND="${RDEPEND}
"
BDEPEND="
	app-arch/rpm2targz
"

src_unpack() {
	use 2308 && (
		mkdir "${WORKDIR}/${P}-2308" || die
		cd "${WORKDIR}/${P}-2308" || die
		rpm_unpack ${P}-2308.rpm
	)

	use 2208 && (
		mkdir "${WORKDIR}/${P}-2208" || die
		cd "${WORKDIR}/${P}-2208" || die
		rpm_unpack ${P}-2208.rpm
	)
}

src_prepare() {
	default
}

mesa-asahi-flatpak_install() {
	local ver="${1}"
	insinto /
	doins -r "${WORKDIR}/${P}-${ver}/var/"
}

src_install() {
	use 2308 && mesa-asahi-flatpak_install "2308"
	use 2208 && mesa-asahi-flatpak_install "2208"
}
