# Copyright 2022 James Calligeros <jcalligeros99@gmail.com>
# Distributed under the terms of the GNU General Public License v2

# NOTE: this builds a version of box64 that is suitable only for
# Apple Silicon devices by using the -DM1 flag. If porting for
# upstream, take this into consideration.

EAPI="7"
PYTHON_COMPAT=( python3_{8..10} )

inherit eutils autotools cmake

DESCRIPTION="box64 - amd64 binary translator for Linux"
HOMEPAGE="https://box86.org/"
LICENSE="MIT"
IUSE="!arm64? ( -dynarec )"
SLOT="0"
KEYWORDS="arm64 ~arm64"

inherit git-r3 distutils-r1
EGIT_REPO_URI="https://github.com/pitSeb/box64.git"
EGIT_CLONE_TYPE="shallow" # --depth=1
EGIT_BRANCH="main"
SRC_URI=""
BDEPEND="
	${BDEPEND}
	dev-vcs/git
"

RDEPEND="
	32bit? ( app-emulation/box86 )
"

DEPEND="
	${RDEPEND}
"

if [[ ${PV} == "9999" ]]; then
	EGIT_COMMIT=""
else
	EGIT_COMMIT="v${PV}"
fi

src_unpack() {
	git-r3_src_unpack
}

src_configure() {
	local mycmakeargs=(
		-DM1=1
		-DCMAKE_BUILD_TYPE=RelWithDebInfo
		-DARM_DYNAREC=$(usex dynarec "ON" "OFF")
	)

	cmake_src_configure
}


src_install() {
	cmake_src_install

	dodoc docs/README.md
}


pkg_postinst() {
	elog "For information on how to properly use box64, head to"
	elog "https://box64.org/"
	elog " "
}

pkg_postrm() {
	ewarn "box64 has been removed, but none of your amd64 software"
	ewarn "has been. Please remove this manually if you are done"
	ewarn "using it."
}
