# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

GIT_COMMIT="aefb89536ab19b76ab33a10032e1f8c2c47fdb15"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://anongit.freedesktop.org/git/virglrenderer.git"
	inherit git-r3
else
	MY_P="${PN}-${P}"
	SRC_URI="https://gitlab.freedesktop.org/virgl/${PN}/-/archive/${GIT_COMMIT}/${PN}-${GIT_COMMIT}.tar.bz2 -> ${PF}.tar.bz2"
	S="${WORKDIR}/${MY_P}"

	KEYWORDS="~amd64 ~arm64 ~loong ~riscv ~x86"
fi

DESCRIPTION="library used implement a virtual 3D GPU used by qemu"
HOMEPAGE="https://virgil3d.github.io/"

S="${WORKDIR}/${PN}-${GIT_COMMIT}"

LICENSE="MIT"
SLOT="0"
IUSE="static-libs"

RDEPEND="
	>=x11-libs/libdrm-2.4.50
	media-libs/libepoxy
	media-libs/mesa
	x11-libs/libX11
"

DEPEND="${RDEPEND}"

# Most of the testsuite cannot run in our sandboxed environment, just don't
# deal with it for now.
RESTRICT="test"

PATCHES="
	${FILESDIR}/${PN}-asahi-native-context.patch
"

src_configure() {
	local emesonargs=(
		-Ddefault_library=$(usex static-libs both shared)
		-Ddrm-asahi-experimental=true
	)

	meson_src_configure
}
