# Copyright 2022 James Calligeros <jcalligeros99@gmail.com>
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python3_{8..10} )

inherit eutils autotools toolchain-funcs

DESCRIPTION="Apple Silicon bootloader and experimentation playground"
HOMEPAGE="https://asahilinux.org/"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~arm64"

BDEPEND="
    sys-devel/make
    sys-apps/dtc"

RDEPEND="
    sys-boot/u-boot
    sys-kernel/asahi-sources"

# We need to do some extra stuff to get a non-tagged git repo
if [[ ${PV} == "9999" ]]; then
	inherit git-r3 distutils-r1
	EGIT_REPO_URI="https://github.com/AsahiLinux/m1n1.git"
	EGIT_CLONE_TYPE="shallow"
	EGIT_SUBMODULES=( '*' )
	EGIT_BRANCH="main"
	SRC_URI=""
	BDEPEND="${BDEPEND}
		dev-vcs/git"
else
	SRC_URI="https://github.com/AsahiLinux/m1n1/archive/refs/tags/v${PV}.tar.gz"
fi

src_unpack() {
	if [[ ${PV} == "9999" ]]; then
		einfo "Using GitHub sources, cloning from AsahiLinux/m1n1..."
		git-r3_src_unpack
	else
		if [[ -n ${A} ]]; then
			unpack ${A}
		fi
	fi
}

src_compile() {
	cd "${S}" || die
	emake CC="$(tc-getCC)" \
	      CXX="$(tc-getCXX)" \
	      LD="$(tc-getLD)" \
	      AR="$(tc-getAR)" \
	      AS="$(tc-getAS)" \
	      NM="$(tc-getNM)" \
	      RANLIB="$(tc-getRANLIB)" \
	      OBJCOPY="$(tc-getOBJCOPY)" \
	      || die "emake failed"
}

src_install() {
	dodir /usr/lib/asahi-boot
	cp ${S}/build/m1n1.bin "${ED%/}"/usr/lib/asahi-boot/m1n1.bin || die
}


pkg_postinst() {
	elog "m1n1 has been installed at /usr/lib/asahi-boot/m1n1.bin"
	elog "You must run update-m1n1 for the new version to be installed"
	elog "in the ESP."
	elog "Please see the Asahi Linux Wiki for more information."
}

pkg_postrm() {
	elog "m1n1 has been removed from /usr/lib/asahi-boot/ but has not"
	elog "been removed from the ESP. You need to do this manually, though"
	elog "you really shouldn't."
}
