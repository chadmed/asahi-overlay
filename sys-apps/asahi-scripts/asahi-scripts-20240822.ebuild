# Copyright 2022 James Calligeros <jcalligeros99@gmail.com>
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

DESCRIPTION="Apple Silicon support scripts"
HOMEPAGE="https://asahilinux.org/"
SRC_URI="https://github.com/AsahiLinux/${PN}/archive/refs/tags/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~arm64"

IUSE="livecd"

BDEPEND="
	dev-build/make
	virtual/udev
"

src_prepare() {
	default
}

src_compile() {
	emake || die "Could not invoke emake"
}

src_install() {
	# For Gentoo releng, we only want the dracut modules
	use livecd && (
		insinto /usr/lib/dracut/modules.d/91kernel-modules-asahi
		doins "${S}"/dracut/modules.d/91kernel-modules-asahi/module-setup.sh

		insinto /usr/lib/dracut/modules.d/99asahi-firmware
		doins "${S}"/dracut/modules.d/99asahi-firmware/install-asahi-firmware.sh
		doins "${S}"/dracut/modules.d/99asahi-firmware/load-asahi-firmware.sh
		doins "${S}"/dracut/modules.d/99asahi-firmware/module-setup.sh
	)

	use livecd || (
		emake DESTDIR="${D}" PREFIX="/usr" SYS_PREFIX="" install-dracut
		emake DESTDIR="${D}" PREFIX="/usr" install-macsmc-battery

		newinitd "${FILESDIR}/${PN}-macsmc-battery.openrc" "macsmc-battery"

		# install gentoo sys config
		insinto /etc/default
		newins "${FILESDIR}"/update-m1n1.gentoo.conf update-m1n1
	)
}

pkg_postinst() {
	if [[ ! -e ${ROOT}/usr/lib/asahi-boot ]]; then
		ewarn "These scripts are intended for use on Apple Silicon"
		ewarn "machines with the Asahi tooling installed! Please"
		ewarn "install sys-boot/m1n1, sys-boot/u-boot and"
		ewarn "sys-firmware/asahi-firmware!"
	fi

	elog "Asahi scripts have been installed to /usr/. For more"
	elog "information on how to use them, please visit the Wiki."

	if [[ -e ${ROOT}/usr/local/share/asahi-scripts/functions.sh ]]; then
		ewarn "You have upgraded to a new version of ${PN}. Please"
		ewarn "remove /usr/local/share/asahi-scripts/,"
		ewarn " /usr/local/bin/update-m1n1, and"
		ewarn "/usr/local/bin/update-vendor-firmware."
	fi

	if [[ -e ${ROOT}/etc/dracut.conf.d/10-apple.conf ]]; then
		ewarn "Please remove /etc/dracut.conf.d/10-apple.conf"
	fi
}
