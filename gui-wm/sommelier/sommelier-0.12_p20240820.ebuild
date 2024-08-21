# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11,12,13} )

inherit meson python-any-r1

DESCRIPTION="Nested Wayland compositor with support for X11 forwarding"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/refs/heads/main/vm_tools/sommelier/"

GIT_HASH="31e06b16f0546e277408ffbebc4e5dded7d3324e"

SRC_URI="
	https://chromium.googlesource.com/chromiumos/platform2/+archive/${GIT_HASH}/vm_tools/sommelier.tar.gz -> ${P}.tar.gz
"

S="${WORKDIR}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

PATCHES="
	${FILESDIR}/${PN}-0.12-disable-vgpu-stride-fix.patch
"

IUSE="test"

RESTRICT="!test? ( test )"

BDEPEND="
	dev-util/wayland-scanner
	$(python_gen_any_dep '
		dev-python/jinja[${PYTHON_USEDEP}]
	')
"

DEPEND="
	media-libs/mesa
	x11-libs/libdrm
	x11-libs/pixman
	x11-libs/libxcb
	x11-libs/libxkbcommon
	dev-libs/wayland
	test? (
		dev-cpp/gtest
	)
"

RDEPEND="
	${DEPEND}
	x11-base/xwayland
"

python_check_deps() {
	python_has_version "dev-python/jinja[${PYTHON_USEDEP}]"
}

src_configure() {
	local emesonargs=(
		-Dxwayland_path="${BROOT}"/usr/bin/Xwayland
		-Dxwayland_gl_driver_path="${EPREFIX}/usr/$(get_libdir)/dri"
		-Dwith_tests=$(usex test true false)
	)
	meson_src_configure
}