# Copyright 2022 chadmed <jcalligeros99@gmail.com>
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"

inherit eutils autotools

DESCRIPTION="Asahi Linux kernel sources"
HOMEPAGE="https://asahilinux.org/"
LICENSE="GPL-2.0 freedist"
INSTALL_DIR=/usr/src/linux-ashai
IUSE="symlink"


# We need to do some extra stuff to get a non-tagged git repo.
if [[ ${PV} == "9999" ]]; then
	inherit git-r3 distutils-r1
	EGIT_REPO_URI="https://github.com/AsahiLinux/linux.git"
	EGIT_CLONE_TYPE="shallow" # --depth=1
	EGIT_BRANCH="asahi"
	SRC_URI=""
	BDEPEND="${BDEPEND}
		dev-vcs/git"
else
	SRC_URI="https://github.com/AsahiLinux/linux/archive/refs/tags/asahi-${PV}.tar.gz -> ${P}.tar.gz"
fi

KEYWORDS="~arm64"
SLOT="0"

RDEPEND="
	app-arch/cpio
	dev-lang/perl
	sys-devel/bc
	sys-devel/bison
	sys-devel/flex
	sys-devel/make
	>=sys-libs/ncurses-5.2
	virtual/libelf
	virtual/pkgconfig"


src_unpack() {
	if [[ ${PV} == "9999" ]]; then
		einfo "Using GitHub sources, nothing to unpack"
	else
		if [[ -n ${A} ]];
			unpack ${A}
		fi
	fi
}

src_install() {
	if [[ -n ${INSTALL_DIR} ]]; then
		einfo "Creating install directory..."
		mkdir -p ${INSTALL_DIR}
	fi
	mv ${WORKDIR}/${P} ${INSTALL_DIR}/
	use symlink && ln -snf ${INSTALL_DIR} /usr/src/linux
}


pkg_postinst() {
	einfo "From here, follow the standard Gentoo Handbook instructions for"
	einfo "building a kernel."
	einfo "Install sys-firmware/applesilicon for proper firmware support."
}

pkg_postrm() {
	einfo "Follow the standard kernel removal/upgrade procedure"
}
