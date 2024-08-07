# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( {17..18} )
LLVM_OPTIONAL=1
PYTHON_COMPAT=( python3_{10..13} )

inherit llvm-r1 meson-multilib python-any-r1 linux-info

MY_P="${P/_/-}"

# $PV is expected to be of following form: 23.2.0_pre20230530
MY_PV="$(ver_cut 5)"

DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="https://www.mesa3d.org/ https://mesa.freedesktop.org/"

SRC_URI="https://gitlab.freedesktop.org/asahi/mesa/-/archive/asahi-${MY_PV}/mesa-asahi-${MY_PV}.tar.gz"
S="${WORKDIR}/mesa-asahi-${MY_PV}"

LICENSE="MIT SGI-B-2.0"
SLOT="0"

KEYWORDS="arm64"

RADEON_CARDS="r300 r600 radeon radeonsi"
VIDEO_CARDS="${RADEON_CARDS} asahi d3d12 freedreno intel lavapipe lima nouveau panfrost v3d vc4 virgl vivante vmware"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS}
	cpu_flags_x86_sse2 d3d9 debug +gles2 +llvm
	lm-sensors opencl +opengl osmesa +proprietary-codecs selinux
	test unwind vaapi valgrind vdpau vulkan
	vulkan-overlay wayland +X xa zink +zstd"
RESTRICT="!test? ( test )"
REQUIRED_USE="
	d3d9? (
		|| (
			video_cards_intel
			video_cards_r300
			video_cards_r600
			video_cards_radeonsi
			video_cards_nouveau
			video_cards_vmware
		)
	)
	llvm? ( ${LLVM_REQUIRED_USE} )
	vulkan-overlay? ( vulkan )
	video_cards_asahi? ( llvm )
	video_cards_lavapipe? ( llvm vulkan )
	video_cards_radeon? ( x86? ( llvm ) amd64? ( llvm ) )
	video_cards_r300?   ( x86? ( llvm ) amd64? ( llvm ) )
	vdpau? ( X )
	xa? ( X )
	zink? ( opengl vulkan )
"

LIBDRM_DEPSTRING=">=x11-libs/libdrm-2.4.119"
RDEPEND="
	>=dev-libs/expat-2.1.0-r3[${MULTILIB_USEDEP}]
	>=media-libs/libglvnd-1.3.2[X?,${MULTILIB_USEDEP}]
	>=sys-libs/zlib-1.2.9[${MULTILIB_USEDEP}]
	unwind? ( sys-libs/libunwind[${MULTILIB_USEDEP}] )
	llvm? (
		$(llvm_gen_dep "
			sys-devel/llvm:\${LLVM_SLOT}[${MULTILIB_USEDEP}]
			opencl? (
				dev-util/spirv-llvm-translator:\${LLVM_SLOT}
				sys-devel/clang:\${LLVM_SLOT}[${MULTILIB_USEDEP}]
			)
			video_cards_asahi? (
				dev-util/spirv-llvm-translator:\${LLVM_SLOT}
				sys-devel/clang:\${LLVM_SLOT}[${MULTILIB_USEDEP}]
			)
		")
		video_cards_r600? (
			virtual/libelf:0=[${MULTILIB_USEDEP}]
		)
		video_cards_radeon? (
			virtual/libelf:0=[${MULTILIB_USEDEP}]
		)
	)
	lm-sensors? ( sys-apps/lm-sensors:=[${MULTILIB_USEDEP}] )
	opencl? (
		>=virtual/opencl-3
		dev-libs/libclc[spirv(-)]
		>=dev-util/spirv-tools-1.3.231.0
		virtual/libelf:0=
	)
	vaapi? (
		>=media-libs/libva-1.7.3:=[${MULTILIB_USEDEP}]
	)
	vdpau? ( >=x11-libs/libvdpau-1.5:=[${MULTILIB_USEDEP}] )
	video_cards_radeonsi? ( virtual/libelf:0=[${MULTILIB_USEDEP}] )
	selinux? ( sys-libs/libselinux[${MULTILIB_USEDEP}] )
	wayland? ( >=dev-libs/wayland-1.18.0[${MULTILIB_USEDEP}] )
	${LIBDRM_DEPSTRING}[video_cards_freedreno?,video_cards_intel?,video_cards_nouveau?,video_cards_vc4?,video_cards_vivante?,video_cards_vmware?,${MULTILIB_USEDEP}]
	X? (
		>=x11-libs/libX11-1.6.2[${MULTILIB_USEDEP}]
		>=x11-libs/libxshmfence-1.1[${MULTILIB_USEDEP}]
		>=x11-libs/libXext-1.3.2[${MULTILIB_USEDEP}]
		>=x11-libs/libXxf86vm-1.1.3[${MULTILIB_USEDEP}]
		>=x11-libs/libxcb-1.16:=[${MULTILIB_USEDEP}]
		x11-libs/libXfixes[${MULTILIB_USEDEP}]
		x11-libs/xcb-util-keysyms[${MULTILIB_USEDEP}]
	)
	zink? ( media-libs/vulkan-loader:=[${MULTILIB_USEDEP}] )
	zstd? ( app-arch/zstd:=[${MULTILIB_USEDEP}] )
"
for card in ${RADEON_CARDS}; do
	RDEPEND="${RDEPEND}
		video_cards_${card}? ( ${LIBDRM_DEPSTRING}[video_cards_radeon] )
	"
done
RDEPEND="${RDEPEND}
	video_cards_radeonsi? ( ${LIBDRM_DEPSTRING}[video_cards_amdgpu] )
"

DEPEND="${RDEPEND}
	video_cards_d3d12? ( >=dev-util/directx-headers-1.613.0[${MULTILIB_USEDEP}] )
	valgrind? ( dev-debug/valgrind )
	wayland? ( >=dev-libs/wayland-protocols-1.33 )
	X? (
		x11-libs/libXrandr[${MULTILIB_USEDEP}]
		x11-base/xorg-proto
	)
"
BDEPEND="
	${PYTHON_DEPS}
	opencl? (
		>=virtual/rust-1.62.0
		>=dev-util/bindgen-0.58.0
		>=dev-build/meson-1.3.1
	)
	app-alternatives/yacc
	app-alternatives/lex
	virtual/pkgconfig
	$(python_gen_any_dep ">=dev-python/mako-0.8.0[\${PYTHON_USEDEP}]")
	video_cards_asahi? (
		dev-libs/libclc[spirv(-)]
	)
	video_cards_intel? (
		~dev-util/intel_clc-${PV}
		dev-libs/libclc[spirv(-)]
		$(python_gen_any_dep "dev-python/ply[\${PYTHON_USEDEP}]")
	)
	vulkan? ( dev-util/glslang )
	wayland? ( dev-util/wayland-scanner )
"

QA_WX_LOAD="
x86? (
	usr/lib/libglapi.so.0.0.0
	usr/lib/libOSMesa.so.8.0.0
	usr/lib/libGLX_mesa.so.0.0.0
)"

pkg_pretend() {
	if use vulkan; then
		if ! use video_cards_d3d12 &&
		   ! use video_cards_freedreno &&
		   ! use video_cards_intel &&
		   ! use video_cards_radeonsi &&
		   ! use video_cards_v3d; then
			ewarn "Ignoring USE=vulkan     since VIDEO_CARDS does not contain d3d12, freedreno, intel, radeonsi, or v3d"
		fi
	fi

	if use vaapi; then
		if ! use video_cards_d3d12 &&
		   ! use video_cards_r600 &&
		   ! use video_cards_radeonsi &&
		   ! use video_cards_nouveau; then
			ewarn "Ignoring USE=vaapi      since VIDEO_CARDS does not contain d3d12, r600, radeonsi, or nouveau"
		fi
	fi

	if use vdpau; then
		if ! use video_cards_d3d12 &&
		   ! use video_cards_r300 &&
		   ! use video_cards_r600 &&
		   ! use video_cards_radeonsi &&
		   ! use video_cards_nouveau; then
			ewarn "Ignoring USE=vdpau      since VIDEO_CARDS does not contain d3d12, r300, r600, radeonsi, or nouveau"
		fi
	fi

	if use xa; then
		if ! use video_cards_freedreno &&
		   ! use video_cards_nouveau &&
		   ! use video_cards_vmware; then
			ewarn "Ignoring USE=xa         since VIDEO_CARDS does not contain freedreno, nouveau, or vmware"
		fi
	fi

	if ! use llvm; then
		use opencl     && ewarn "Ignoring USE=opencl     since USE does not contain llvm"
	fi

	if use osmesa && ! use llvm; then
		ewarn "OSMesa will be slow without enabling USE=llvm"
	fi
}

python_check_deps() {
	python_has_version -b ">=dev-python/mako-0.8.0[${PYTHON_USEDEP}]" || return 1
	if use llvm && use vulkan && use video_cards_intel && use amd64; then
		python_has_version -b "dev-python/ply[${PYTHON_USEDEP}]" || return 1
	fi
}

pkg_setup() {
	# warning message for bug 459306
	if use llvm && has_version sys-devel/llvm[!debug=]; then
		ewarn "Mismatch between debug USE flags in media-libs/mesa and sys-devel/llvm"
		ewarn "detected! This can cause problems. For details, see bug 459306."
	fi

	if use video_cards_intel ||
	   use video_cards_radeonsi; then
		if kernel_is -ge 5 11 3; then
			CONFIG_CHECK="~KCMP"
		elif kernel_is -ge 5 11; then
			CONFIG_CHECK="~CHECKPOINT_RESTORE"
		elif kernel_is -ge 5 10 20; then
			CONFIG_CHECK="~KCMP"
		else
			CONFIG_CHECK="~CHECKPOINT_RESTORE"
		fi
		linux-info_pkg_setup
	fi

	use llvm && llvm-r1_pkg_setup
	python-any-r1_pkg_setup
}

src_prepare() {
	default
	sed -i -e "/^PLATFORM_SYMBOLS/a '__gentoo_check_ldflags__'," \
		bin/symbols-check.py || die # bug #830728
	# patch version string
	sed -i -e "s/devel/asahi${MY_PV}/" VERSION
}

multilib_src_configure() {
	local emesonargs=()

	local platforms
	use X && platforms+="x11"
	use wayland && platforms+=",wayland"
	emesonargs+=(-Dplatforms=${platforms#,})

	if use video_cards_intel ||
	   use video_cards_r300 ||
	   use video_cards_r600 ||
	   use video_cards_radeonsi ||
	   use video_cards_nouveau ||
	   use video_cards_vmware; then
		emesonargs+=($(meson_use d3d9 gallium-nine))
	else
		emesonargs+=(-Dgallium-nine=false)
	fi

	if use video_cards_d3d12 ||
	   use video_cards_r600 ||
	   use video_cards_radeonsi ||
	   use video_cards_nouveau; then
		emesonargs+=($(meson_feature vaapi gallium-va))
		use vaapi && emesonargs+=( -Dva-libs-path="${EPREFIX}"/usr/$(get_libdir)/va/drivers )
	else
		emesonargs+=(-Dgallium-va=disabled)
	fi

	if use video_cards_d3d12; then
		emesonargs+=($(meson_feature vaapi gallium-d3d12-video))
	fi

	if use video_cards_d3d12 ||
	   use video_cards_r300 ||
	   use video_cards_r600 ||
	   use video_cards_radeonsi ||
	   use video_cards_nouveau; then
		emesonargs+=($(meson_feature vdpau gallium-vdpau))
	else
		emesonargs+=(-Dgallium-vdpau=disabled)
	fi

	if use video_cards_freedreno ||
	   use video_cards_nouveau ||
	   use video_cards_vmware; then
		emesonargs+=($(meson_feature xa gallium-xa))
	else
		emesonargs+=(-Dgallium-xa=disabled)
	fi

	if use video_cards_asahi ||
	   use video_cards_freedreno ||
	   use video_cards_lima ||
	   use video_cards_panfrost ||
	   use video_cards_v3d ||
	   use video_cards_vc4 ||
	   use video_cards_vivante; then
		gallium_enable -- kmsro
	fi

	gallium_enable -- swrast
	gallium_enable video_cards_asahi asahi
	gallium_enable video_cards_freedreno freedreno
	gallium_enable video_cards_intel crocus i915 iris
	gallium_enable video_cards_lima lima
	gallium_enable video_cards_d3d12 d3d12
	gallium_enable video_cards_nouveau nouveau
	gallium_enable video_cards_panfrost panfrost
	gallium_enable video_cards_v3d v3d
	gallium_enable video_cards_vc4 vc4
	gallium_enable video_cards_virgl virgl
	gallium_enable video_cards_vivante etnaviv
	gallium_enable video_cards_vmware svga
	gallium_enable zink zink

	gallium_enable video_cards_r300 r300
	gallium_enable video_cards_r600 r600
	gallium_enable video_cards_radeonsi radeonsi
	if ! use video_cards_r300 && \
		! use video_cards_r600; then
		gallium_enable video_cards_radeon r300 r600
	fi

	if use llvm && (use opencl || use video_cards_asahi); then
		PKG_CONFIG_PATH="$(get_llvm_prefix)/$(get_libdir)/pkgconfig"
		if use opencl; then
			# See https://gitlab.freedesktop.org/mesa/mesa/-/blob/main/docs/rusticl.rst
			emesonargs+=(
				$(meson_native_true gallium-rusticl)
				-Drust_std=2021
			)
		fi
	fi

	if use vulkan; then
		vulkan_enable video_cards_lavapipe swrast
		vulkan_enable video_cards_freedreno freedreno
		vulkan_enable video_cards_intel intel intel_hasvk
		vulkan_enable video_cards_d3d12 microsoft-experimental
		vulkan_enable video_cards_radeonsi amd
		vulkan_enable video_cards_v3d broadcom
	fi

	driver_list() {
		local drivers="$(sort -u <<< "${1// /$'\n'}")"
		echo "${drivers//$'\n'/,}"
	}

	local vulkan_layers
	use vulkan && vulkan_layers+="device-select"
	use vulkan-overlay && vulkan_layers+=",overlay"
	emesonargs+=(-Dvulkan-layers=${vulkan_layers#,})

	if use opengl && use X; then
		emesonargs+=(-Dglx=dri)
	else
		emesonargs+=(-Dglx=disabled)
	fi

	use debug && EMESON_BUILDTYPE=debug

	emesonargs+=(
		$(meson_use test build-tests)
		-Dshared-glapi=enabled
		-Ddri3=enabled
		-Dexpat=enabled
		-Dglvnd=true
		$(meson_use opengl)
		$(meson_feature opengl gbm)
		$(meson_feature opengl gles1)
		$(meson_feature gles2)
		#$(meson_feature opengl glvnd)
		$(meson_feature opengl egl)
		$(meson_feature llvm)
		$(meson_feature lm-sensors lmsensors)
		$(meson_use osmesa)
		$(meson_use selinux)
		$(meson_feature unwind libunwind)
		$(meson_native_use_feature video_cards_intel intel-rt)
		$(meson_feature zstd)
		$(meson_use cpu_flags_x86_sse2 sse2)
		-Dintel-clc=$(usex video_cards_intel system auto)
		-Dvalgrind=$(usex valgrind auto disabled)
		-Dvideo-codecs=$(usex proprietary-codecs "all" "all_free")
		-Dgallium-drivers=$(driver_list "${GALLIUM_DRIVERS[*]}")
		-Dvulkan-drivers=$(driver_list "${VULKAN_DRIVERS[*]}")
		-Db_ndebug=$(usex debug false true)
	)
	meson_src_configure
}

multilib_src_test() {
	meson_src_test -t 100
}

# $1 - VIDEO_CARDS flag (check skipped for "--")
# other args - names of DRI drivers to enable
gallium_enable() {
	if [[ $1 == -- ]] || use $1; then
		shift
		GALLIUM_DRIVERS+=("$@")
	fi
}

vulkan_enable() {
	if [[ $1 == -- ]] || use $1; then
		shift
		VULKAN_DRIVERS+=("$@")
	fi
}
