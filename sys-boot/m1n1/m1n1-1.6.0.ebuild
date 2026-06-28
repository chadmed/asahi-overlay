# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Since we use aarch64-unknown-none-softfload, we need to build core and alloc.
# These crates are from pycargoebuild ${RUST}/lib/rustlib/src/rust/library/core/
# XXX: Will these break on every Rust update? I'd rather not pin a specific rust
# version...
CRATES_CORE="
	addr2line@0.25.1
	adler2@2.0.1
	cc@1.2.0
	cfg-if@1.0.4
	dlmalloc@0.2.11
	foldhash@0.2.0
	fortanix-sgx-abi@0.6.1
	getopts@0.2.24
	gimli@0.32.3
	hashbrown@0.16.1
	hermit-abi@0.5.2
	libc@0.2.178
	memchr@2.7.6
	miniz_oxide@0.8.9
	moto-rt@0.16.0
	object@0.37.3
	r-efi-alloc@2.1.0
	r-efi@5.3.0
	rand@0.9.2
	rand_core@0.9.3
	rand_xorshift@0.4.0
	rustc-demangle@0.1.27
	rustc-literal-escaper@0.0.7
	shlex@1.3.0
	unwinding@0.2.8
	vex-sdk@0.27.1
	wasi@0.11.1+wasi-snapshot-preview1
	wasi@0.14.4+wasi-0.2.4
	windows-link@0.2.1
	windows-sys@0.60.2
	windows-targets@0.53.5
	windows_aarch64_gnullvm@0.53.1
	windows_aarch64_msvc@0.53.1
	windows_i686_gnu@0.53.1
	windows_i686_gnullvm@0.53.1
	windows_i686_msvc@0.53.1
	windows_x86_64_gnu@0.53.1
	windows_x86_64_gnullvm@0.53.1
	windows_x86_64_msvc@0.53.1
	wit-bindgen@0.45.1
"

CRATES_M1N1="
	bitflags@2.13.0
	log@0.4.33
	uuid@1.23.4
"

CRATES="
	${CRATES_CORE}
	${CRATES_M1N1}
"

declare -A GIT_CRATES=(
	[fatfs]='https://github.com/rafalh/rust-fatfs;4eccb50d011146fbed20e133d33b22f3c27292e7;rust-fatfs-%commit%'
)

RUST_MIN_VER="1.89.0"
RUST_REQ_USE="rust-src"

inherit cargo rust

DESCRIPTION="Apple Silicon bootloader and experimentation playground"
HOMEPAGE="https://asahilinux.org/"
SRC_URI="
	https://github.com/AsahiLinux/m1n1/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz
	${CARGO_CRATE_URIS}
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~arm64"
IUSE="clang"

BDEPEND="dev-build/make"

RDEPEND="
	sys-boot/u-boot
	|| (
		sys-kernel/asahi-sources
		virtual/dist-kernel:asahi
	   )
"

BDEPEND="${BDEPEND}
	clang? ( llvm-core/clang )
"

PATCHES="
	${FILESDIR}/${P}-unvendor-fatfs.patch
"

src_compile() {
	cd "${S}" || die
	if use clang; then
		emake USE_CLANG=1 \
		RELEASE=1 \
		ARCH="${CHOST}" \
		BUILDSTD=1
	else
		emake USE_CLANG=0 \
		RELEASE=1 \
		ARCH="${CHOST}-" \
		BUILDSTD=1
	fi
}

src_install() {
	dodir /usr/lib/asahi-boot
	cp "${S}"/build/m1n1.bin "${ED}"/usr/lib/asahi-boot/m1n1.bin || die
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
