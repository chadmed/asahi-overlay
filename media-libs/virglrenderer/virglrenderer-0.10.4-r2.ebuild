# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://anongit.freedesktop.org/git/virglrenderer.git"
	inherit git-r3
else
	MY_P="${PN}-cacafff69205a62758a22ef73c1334057f72e5d6"
	SRC_URI="https://gitlab.freedesktop.org/slp/virglrenderer/-/archive/cacafff69205a62758a22ef73c1334057f72e5d6/virglrenderer-cacafff69205a62758a22ef73c1334057f72e5d6.tar.gz -> ${P}-slp.tar.gz"
	S="${WORKDIR}/${MY_P}"

	KEYWORDS="~arm64"
fi

DESCRIPTION="library used implement a virtual 3D GPU used by qemu"
HOMEPAGE="https://virgil3d.github.io/"

LICENSE="MIT"
SLOT="0"
IUSE="static-libs +native-context"

RDEPEND="
	>=x11-libs/libdrm-2.4.50
	media-libs/libepoxy"

DEPEND="${RDEPEND}"

# Most of the testsuite cannot run in our sandboxed environment, just don't
# deal with it for now.
RESTRICT="test"

src_configure() {
	local emesonargs=(
		-Ddefault_library=$(usex static-libs both shared)
		-Ddrm-msm-experimental=$(usex native-context true false)
		-Ddrm-asahi-experimental=$(usex native-context true false)
	)

	meson_src_configure
}

src_install() {
	meson_src_install
	find "${ED}/usr" -name 'lib*.la' -delete
}
