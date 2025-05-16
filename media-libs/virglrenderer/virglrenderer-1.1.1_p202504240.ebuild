# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://gitlab.freedesktop.org/asahi/virglrenderer.git"
	inherit git-r3
else
	pv_full="$(ver_cut 5)"
	pv_date="$((pv_full / 10))"
	MY_PV="asahi-${pv_date}"
	MY_P="${PN}-${MY_PV}"
	SRC_URI="https://gitlab.freedesktop.org/asahi/${PN}/-/archive/${MY_PV}/${MY_P}.tar.bz2"
	S="${WORKDIR}/${MY_P}"

	KEYWORDS="~amd64 ~arm64"
fi

DESCRIPTION="library used implement a virtual 3D GPU used by qemu"
HOMEPAGE="https://virgil3d.github.io/"

LICENSE="MIT"
SLOT="0"
IUSE="static-libs"

RDEPEND="
	>=x11-libs/libdrm-2.4.50
	media-libs/libepoxy
	=media-libs/mesa-25.1.0-r100
	x11-libs/libX11
"

DEPEND="${RDEPEND}"

# Most of the testsuite cannot run in our sandboxed environment, just don't
# deal with it for now.
RESTRICT="test"

src_configure() {
	local emesonargs=(
		-Ddefault_library=$(usex static-libs both shared)
		-Ddrm-renderers=asahi-experimental
	)

	meson_src_configure
}
