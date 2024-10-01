# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 18 )

inherit rpm

DESCRIPTION="Asahi OpenGL Extension for Flatpak"
HOMEPAGE="https://asahilinux.org https://flatpak.org"

SRC_URI="
2308? (
	https://download.copr.fedorainfracloud.org/results/@asahi/flatpak/fedora-40-aarch64/08093406-mesa-asahi-23.08-flatpak/mesa-asahi-23.08-flatpak-24.3.0~asahipre20240930-1.aarch64.rpm  -> ${P}-2308.rpm
)

2408? (
	https://download.copr.fedorainfracloud.org/results/@asahi/flatpak/fedora-40-aarch64/08093396-mesa-asahi-24.08-flatpak/mesa-asahi-24.08-flatpak-24.3.0~asahipre20240930-1.aarch64.rpm -> ${P}-2408.rpm
)
"

S="${WORKDIR}"

LICENSE="MIT SGI-B-2.0"
SLOT="0"

KEYWORDS="~arm64"

IUSE="+2308 +2408"
REQUIRED_USE="|| ( 2308 2408 )"

RDEPEND="
	sys-apps/flatpak
	~media-libs/mesa-${PV}
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

	use 2408 && (
		mkdir "${WORKDIR}/${P}-2408" || die
		cd "${WORKDIR}/${P}-2408" || die
		rpm_unpack ${P}-2408.rpm
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
	use 2408 && mesa-asahi-flatpak_install "2408"
}
