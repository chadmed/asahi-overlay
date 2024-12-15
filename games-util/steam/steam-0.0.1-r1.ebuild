# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

STEAMVER="1.0.0.81"
ARM64_WRAPPER_COMMIT="fb3e8aeaffe5bb374b34f2eacc91130a05b17b21"

DESCRIPTION="Steam launcher bundled with AArch64/ARM64 wrapper for Asahi Linux systems"
HOMEPAGE="
	https://steampowered.com/
	https://github.com/chadmed/steam-aarch64
"

SRC_URI="
	https://repo.steampowered.com/steam/archive/stable/steam_${STEAMVER}.tar.gz
	https://github.com/chadmed/steam-aarch64/archive/${ARM64_WRAPPER_COMMIT}.tar.gz -> ${PN}-aarch64.tar.gz
"

S="${WORKDIR}"

LICENSE="GPL-2+ ValveSteamLicense MIT"
SLOT="0"

KEYWORDS="-* ~arm64"

RDEPEND="
	app-emulation/FEX
	app-emulation/muvm
	gnome-extra/zenity
"

src_unpack() {
	default
}

src_configure() {
	true
}
src_compile() {
	true
}

src_install() {
	cd "${WORKDIR}/steam-launcher" || die
	emake DESTDIR="${D}" \
		install-bin \
		install-docs \
		install-icons \
		install-bootstrap \
		install-desktop \
		install-appdata

	# Install the wrapper manually
	cd "${WORKDIR}/steam-aarch64-${ARM64_WRAPPER_COMMIT}" || die
	dobin {steam-aarch64,steam-muvm}
	newmenu steam-aarch64.desktop steam.desktop
}

pkg_postinst() {
	xdg_pkg_postinst
	einfo "Steam has been installed. To launch steam, use the desktop entry or"
	einfo "run /usr/bin/steam-aarch64 from the terminal."
}

pkg_postrm() {
	xdg_pkg_postrm
}
