# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop linux-info prefix xdg

DESCRIPTION="Installer, launcher and supplementary files for Valve's Steam client"
HOMEPAGE="https://store.steampowered.com"

# emerge -u dev-python/{requests,vdf}
# python <<EOF | sort
# import requests, vdf
# platform = "linuxarm64"
# req = requests.get(f"https://client-update.steamstatic.com/steam_client_publicbeta_{platform}")
# for k, v in vdf.loads(req.text)[platform].items():
# 	if (
# 		isinstance(v, dict) and
# 		k[-11:] == f"_{platform}" and
# 		k[0:-11] in ("bins_linuxarm64")
# 	):
# 		print("https://client-update.steamstatic.com/" + v['file'])
# EOF

SRC_URI="
	https://client-update.steamstatic.com/bins_linuxarm64_linuxarm64.zip.758364d37b7837e73143c60fc4bd07b1c12013f6
	https://repo.steampowered.com/steam/archive/stable/steam_${PV%_p*}.tar.gz
"
S="${WORKDIR}/${PN}"

LICENSE="ValveSteamLicense MIT"
SLOT="0"
KEYWORDS="~arm64"
IUSE="+desktop-portal +dialogs +joystick +muvm +pulseaudio steamvr trayicon +udev udisks video_cards_nvidia +vulkan wayland"
RESTRICT="bindist mirror test"

BDEPEND="
	app-arch/libarchive
	app-misc/pax-utils
"
RDEPEND="
	app-alternatives/tar
	app-arch/xz-utils
	app-shells/bash
	media-libs/fontconfig
	media-libs/libglvnd[X]
	media-libs/openal
	!sys-apps/dbus[-X]
	sys-process/lsof
	virtual/libudev
	virtual/ttf-fonts
	!x11-libs/cairo[-X]
	x11-libs/gtk+:2

	desktop-portal? ( sys-apps/xdg-desktop-portal )
	dialogs? ( || (
		>=gnome-extra/zenity-3
		x11-terms/xterm
	) )
	joystick? (
		udev? ( games-util/game-device-udev-rules )
		wayland? ( >=x11-base/xwayland-23.2.1[libei(+)] )
	)
	muvm? ( >=app-emulation/muvm-0.2 )
	pulseaudio? ( media-libs/libpulse )
	!pulseaudio? ( media-sound/apulse )
	steamvr? ( sys-apps/usbutils )
	trayicon? ( dev-libs/libappindicator:2 )
	udisks? ( sys-fs/udisks:2 )
	video_cards_nvidia? (
		x11-drivers/nvidia-drivers[X]
		vulkan? ( media-libs/vulkan-layers[wayland?,X] )
	)
	!video_cards_nvidia? (
		media-libs/mesa[opengl,X]
	)
	vulkan? ( media-libs/vulkan-loader[wayland?,X] )
"

PATCHES=(
	"${FILESDIR}"/bin_steam.patch
)

pkg_setup() {
	local CONFIG_CHECK=""

	use joystick && CONFIG_CHECK+=" ~INPUT_UINPUT"
	local ERROR_INPUT_UINPUT="CONFIG_INPUT_UINPUT is required for virtual controller support."

	linux-info_pkg_setup
}

src_unpack() {
	unpack steam_${PV%_p*}.tar.gz
	mkdir -p "${S}"/bootstrap || die
	cd "${S}"/bootstrap || die

	local zip
	for zip in ${A}; do
		[[ ${zip} == *.zip.* ]] || continue
		echo ">>> Unpacking ${zip} to ${PWD}"
		# Valve's zip files have backslashes instead of forward slashes.
		bsdtar -cf - "@${DISTDIR}/${zip}" | gtar -xf - --xform='s:\\:/:g' || die
	done
}

src_prepare() {
	default

	# Allow the desktop launcher to use wrappers from the PATH.
	sed -i "s:/usr/bin/::g" steam.desktop || die

	cd bootstrap || die

	# Some of Valve's zip files lack executable bits.
	scanelf -Rqi . | cut -d" " -f3 | xargs chmod a+x || die
	find -type f -exec awk '/^#!/ {print FILENAME} {nextfile}' {} + | xargs chmod a+x || die
}

src_configure() {
	if [[ $(getconf PAGESIZE) != 4096 ]] && ! use muvm; then
		die "USE=muvm is required when PAGESIZE != 4096"
	fi
}

src_compile() {
	cd bootstrap || die
	ebegin "Recreating bootstraplinux_steamrtarm64.tar.xz for the arm64 client"
	tar -Jcf "${S}"/bootstraplinux_steamrtarm64.tar.xz * || die
	eend $?
}

src_install() {
	emake install-{appdata,icons} \
		DESTDIR="${D}" PREFIX="${EPREFIX}/usr"

	newbin "$(prefixify_ro "${FILESDIR}"/steam-wrapper.sh)" steam
	exeinto /usr/lib/steam
	doexe "$(prefixify_ro bin_steam.sh)"
	domenu steam.desktop

	insinto /usr/lib/steam
	doins bootstraplinux_steamrtarm64.tar.xz

	dodoc README debian/changelog
	doman steam.6
}

pkg_postinst() {
	xdg_pkg_postinst
	echo

	elog "Execute ${EPREFIX}/usr/bin/steam to download and install the actual"
	elog "client into your home folder. After installation, the script also"
	elog "starts the client from your home folder."
	echo

	ewarn "The Steam client and the games are _not_ controlled by Portage."
	ewarn "Updates are handled by the client itself."
	echo

	if ! use desktop-portal; then
		ewarn "You have disabled desktop-portal, which is not supported. An"
		ewarn "xdg-desktop-portal backend is needed for file pickers and other desktop"
		ewarn "components to work, e.g. adding a non-Steam game or new library folder."
		echo
	fi

	if ! has_version "gnome-extra/zenity"; then
		ewarn "Valve does not provide a xterm fallback for all calls of zenity."
		ewarn "Please install gnome-extra/zenity for full support."
		echo
	fi
}
