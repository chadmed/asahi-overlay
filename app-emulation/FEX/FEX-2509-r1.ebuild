# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 19 20 21 )
LLVM_OPTIONAL=1

inherit flag-o-matic cmake toolchain-funcs llvm-r1 check-reqs

DESCRIPTION="A fast usermode x86 and x86-64 emulator for Arm64 Linux"
HOMEPAGE="https://fex-emu.com"

JEMALLOC_HASH="ce24593018ca5d5af7e5661ceda9744e02b59f8f"
JEMALLOC_GLIBC_HASH="8436195ad5e1bc347d9b39743af3d29abee59f06"
CPP_OPTPARSE_HASH="9f94388a339fcbb0bc95c17768eb786c85988f6e"
ROBIN_MAP_HASH="d5683d9f1891e5b04e3e3b2192b5349dc8d814ea"

# This need to be vendored since thunk generator does not support the latest version
VULKAN_HEADERS_HASH="cacef3039d277c448c89336290ec3937270b0996"

SRC_URI="
	https://github.com/FEX-Emu/jemalloc/archive/${JEMALLOC_HASH}.tar.gz -> jemalloc-${JEMALLOC_HASH}.tar.gz
	https://github.com/FEX-Emu/jemalloc/archive/${JEMALLOC_GLIBC_HASH}.tar.gz -> jemalloc-glibc-${JEMALLOC_GLIBC_HASH}.tar.gz
	https://github.com/Sonicadvance1/cpp-optparse/archive/${CPP_OPTPARSE_HASH}.tar.gz -> cpp-optparse-${CPP_OPTPARSE_HASH}.tar.gz
	https://github.com/FEX-Emu/robin-map/archive/${ROBIN_MAP_HASH}.tar.gz -> robin-map-${ROBIN_MAP_HASH}.tar.gz
	thunks? (
		https://github.com/KhronosGroup/Vulkan-Headers/archive/${VULKAN_HEADERS_HASH}.tar.gz -> Vulkan-Headers-${VULKAN_HEADERS_HASH}.tar.gz
	)
	https://github.com/FEX-Emu/${PN}/archive/refs/tags/${P}.tar.gz
"

S="${WORKDIR}/${PN}-${P}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~arm64"
BDEPEND="
	llvm-core/clang
	llvm-core/llvm
	thunks? (
		sys-fs/squashfs-tools
		$(llvm_gen_dep '
			llvm-core/clang:${LLVM_SLOT}=
			llvm-core/llvm:${LLVM_SLOT}=
		')
	)
"
RDEPEND="
	dev-libs/xxhash
	>=dev-libs/libfmt-11.0.2:=
	qt6? (
		dev-qt/qtbase:6[gui,wayland(-),widgets,X(-)]
		dev-qt/qtdeclarative:6
	)
	thunks? (
		x11-libs/libX11
		x11-libs/libdrm
		dev-libs/wayland
		media-libs/alsa-lib
		media-libs/libglvnd
		x11-libs/libxcb
	)
	>=app-emulation/fex-rootfs-gentoo-20250904-r1
"
DEPEND="
	>=sys-kernel/linux-headers-6.14
	${RDEPEND}
"

PATCHES="
	${FILESDIR}/${PN}-2503-unvendor-drm-headers.patch
	${FILESDIR}/${PN}-2503-thunkgen-gcc-install-dir.patch
"

IUSE="+fexconfig +qt6 +thunks"

REQUIRED_USE="
	fexconfig? ( qt6 )
	thunks? ( ${LLVM_REQUIRED_USE} )
"

pkg_pretend() {
	use thunks || return
	CHECKREQS_DISK_BUILD=4G
	check-reqs_pkg_pretend
}

pkg_setup() {
	use thunks || return
	CHECKREQS_DISK_BUILD=4G
	check-reqs_pkg_pretend
	llvm-r1_pkg_setup
}

src_unpack() {
	default
	local -A deps=(
		jemalloc "jemalloc-${JEMALLOC_HASH}"
		jemalloc_glibc "jemalloc-${JEMALLOC_GLIBC_HASH}"
		robin-map "robin-map-${ROBIN_MAP_HASH}"
	)
	use thunks && deps[Vulkan-Headers]="Vulkan-Headers-${VULKAN_HEADERS_HASH}"
	for dep in "${!deps[@]}"; do
		rmdir "${S}/External/${dep}" || die
		mv "${WORKDIR}/${deps[${dep}]}" "${S}/External/${dep}"
	done
	rmdir "${S}/Source/Common/cpp-optparse" || die
	mv "${WORKDIR}/cpp-optparse-${CPP_OPTPARSE_HASH}" "${S}/Source/Common/cpp-optparse" || die
	cp "${FILESDIR}/toolchain_x86_32.cmake" "${S}/Data/CMake/" || die
	cp "${FILESDIR}/toolchain_x86_64.cmake" "${S}/Data/CMake/" || die
	unsquashfs -d "${WORKDIR}/fex-rootfs" "${ESYSROOT}/usr/share/fex-emu-rootfs-layers/gentoo/images/00-base.sqfs" || die
	unsquashfs -d "${WORKDIR}/fex-rootfs" -f "${ESYSROOT}/usr/share/fex-emu-rootfs-layers/gentoo/extra/chroot.sqfs" || die
}

src_configure() {
	if ! tc-is-clang ; then
		AR=llvm-ar
		CC=clang
		CXX=clang++
		NM=llvm-nm
		RANLIB=llvm-ranlib
		STRIP=llvm-strip

		strip-unsupported-flags
	fi

	local mycmakeargs=(
		-DBUILD_TESTS=False
		-DENABLE_CCACHE=False
		-DENABLE_LTO=$(if tc-is-lto; then echo True; else echo False; fi)
		-DBUILD_FEXCONFIG=$(usex fexconfig)
		-DBUILD_THUNKS=$(usex thunks)
		-DENABLE_CLANG_THUNKS=True
	)

	if use thunks; then
		mycmakeargs+=(
			-DX86_DEV_ROOTFS="${WORKDIR}/fex-rootfs"
		)
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install
	tc-is-lto && dostrip -x /usr/lib/libFEXCore.a
	rm "${ED}/usr/share/man/man1/FEX.1.gz" || die
	if use thunks; then
		dostrip -x /usr/share/fex-emu/GuestThunks{,_32}/
	fi
}

pkg_postinst() {
	if [[ "$(getconf PAGESIZE)" -ne 4096 ]] && ! type -P "${EPREFIX}/usr/bin/muvm" >/dev/null ; then
		ewarn "Your system page size is not 4096 and as such"
		ewarn "you need to install app-emulation/muvm or a similar solution"
		ewarn "for FEX to work on your machine."
	fi
}
