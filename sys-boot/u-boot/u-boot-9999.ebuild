# Copyright 2022 James Calligeros <jcalligeros99@gmail.com>
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python3_{10..11} )

inherit eutils autotools git-r3 distutils-r1

DESCRIPTION="Asahi Linux fork of Das U-Boot"
HOMEPAGE="https://asahilinux.org/"
LICENSE="GPL-2"
KEYWORDS=""
SLOT="0"
EGIT_REPO_URI="https://github.com/AsahiLinux/u-boot.git"
EGIT_CLONE_TYPE="shallow"

BDEPEND="
    app-arch/cpio
	dev-lang/perl
	sys-devel/bc
	sys-devel/bison
	sys-devel/flex
	sys-devel/make
	>=sys-libs/ncurses-5.2
	virtual/libelf
	virtual/pkgconfig
    sys-apps/dtc
    dev-vcs/git"

RDEPEND="${BDEPEND}"

# We need to do some extra stuff to get a non-tagged git repo
if [[ ${PV} == "9999" ]]; then
	EGIT_BRANCH="asahi"
else
	EGIT_BRANCH="releng/installer-release"
fi

src_unpack() {
    einfo "Using GitHub sources, cloning from AsahiLinux/u-boot..."
    git-r3_src_unpack
}

src_configure() {
    emake apple_m1_defconfig || die "failed to apply defconfig!"
}

src_compile() {
    cd "${S}" || die
    emake || die "emake failed"
}

src_install() {
	dodir /usr/lib/asahi-boot
	cp ${S}/u-boot-nodtb.bin "${ED%/}"/usr/lib/asahi-boot/u-boot-nodtb.bin || die
}


pkg_postinst() {
	elog "U-Boot has been installed to /usr/lib/asahi-boot/u-boot-nodtb.bin."
	elog "You must run update-m1n1 for the new version to be installed"
	elog "in the ESP."
	elog "Please see the Asahi Linux Wiki for more information."
}

pkg_postrm() {
	elog "U-Boot has been removed from /usr/lib/asahi-boot/ but has not"
	elog "been removed from the ESP. You need to do this manually, though"
	elog "you really shouldn't."
}
