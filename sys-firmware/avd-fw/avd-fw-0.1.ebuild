# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 19 20 21 22 23)

inherit meson llvm-r2

DESCRIPTION="Firmware for Apple silicon video decoder"
HOMEPAGE="https://github.com/AsahiLinux/avd-fw"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/asahilinux/avd-fw.git"
	inherit git-r3
else
	SRC_URI="https://github.com/AsahiLinux/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
	KEYWORDS="~arm64"
fi

LICENSE="MIT"
SLOT="0"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND="
	llvm-core/clang
	llvm-core/llvm
	llvm-core/lld
"

src_unpack() {
	if [[ ${PV} == 9999 ]]; then
		git-r3_src_unpack
	else
		unpack ${P}.tar.gz
	fi
}

src_configure() {
	local emesonargs=()

	emesonargs+=(--libdir=lib)

	emesonargs+=(-Dfirmwaredir=firmware/updates)

	emesonargs+=(--cross-file=./llvm.ini)

	meson_src_configure
}
