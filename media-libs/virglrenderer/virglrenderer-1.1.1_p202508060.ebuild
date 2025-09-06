# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://anongit.freedesktop.org/git/virglrenderer.git"
	inherit git-r3
else
	COMMIT="b997bc18fafdcb8e563b7b07b54412ea61e12082"
	MY_P="${PN}-${COMMIT}"
	SRC_URI="https://gitlab.freedesktop.org/virgl/${PN}/-/archive/${COMMIT}/${MY_P}.tar.bz2 -> ${P}.tar.bz2"
	S="${WORKDIR}/${MY_P}"

	KEYWORDS="~arm64"
fi

DESCRIPTION="Library used implement a virtual 3D GPU used by qemu"
HOMEPAGE="https://virgil3d.github.io/"

LICENSE="MIT"
SLOT="0"
IUSE="static-libs test venus vaapi video_cards_amdgpu video_cards_asahi video_cards_freedreno"
# Most of the testsuite cannot run in our sandboxed environment, just don't
# deal with it for now.
RESTRICT="!test? ( test ) test"

RDEPEND="
	>=x11-libs/libdrm-2.4.121
	media-libs/libepoxy
	venus? ( media-libs/vulkan-loader )
	vaapi? ( media-libs/libva:= )
	video_cards_asahi? (
		!<media-libs/mesa-25.2.0
		|| ( !<=app-emulation/fex-rootfs-gentoo-20250425
			 !<=app-emulation/fex-rootfs-mesa-asahi-20250425
		)
	)
"
DEPEND="
	${RDEPEND}
	sys-kernel/linux-headers
"

src_configure() {
	local -a gpus=()
	use video_cards_amdgpu && gpus+=( amdgpu-experimental )
	use video_cards_asahi && gpus+=( asahi )
	use video_cards_freedreno && gpus+=( msm )

	local emesonargs=(
		-Ddefault_library=$(usex static-libs both shared)
		-Ddrm-renderers=$(IFS=,; echo "${gpus[*]}")
		$(meson_use test tests)
		$(meson_use venus)
		$(meson_use vaapi video)
	)

	meson_src_configure
}
