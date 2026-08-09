# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	bitflags@2.13.0
	log@0.4.33
	uuid@1.23.4
"

declare -A GIT_CRATES=(
	[fatfs]='https://github.com/rafalh/rust-fatfs;4eccb50d011146fbed20e133d33b22f3c27292e7;rust-fatfs-%commit%'
)

RUST_MIN_VER="1.89.0"
RUST_REQ_USE="rust-src"

inherit cargo

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

# rust-bin is not suitable since we need the aarch64-unknown-none-softfloat target
BDEPEND="${BDEPEND}
	dev-lang/rust[rust-src]
	clang? ( llvm-core/clang )
"

src_compile() {
	cd "${S}" || die
	if use clang; then
		emake USE_CLANG=1 \
		RELEASE=1 \
		ARCH="${CHOST}"
	else
		emake USE_CLANG=0 \
		RELEASE=1 \
		ARCH="${CHOST}-"
	fi
}

# pkg_pretend is too early for this check, since we might not have dev-lang/rust at
# that point if this is pulled in as part of a new install
src_prepare() {
	if [[ ! -d "${BROOT}"/usr/lib/rustlib/aarch64-unknown-none-softfloat/ ]]; then
		eerror "aarch64-unknown-none-softfloat Rust target is not installed!"
		eerror "Please rebuild dev-lang/rust with aarch64-unknown-none-softfloat"
		eerror "support, or alternatively use sys-boot/m1n1-bin."
		die "Rust target dependency not met: aarch64-unknown-none-softfloat"
	else
		default
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
