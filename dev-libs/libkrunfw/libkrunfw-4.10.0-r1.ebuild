# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )

inherit python-any-r1 toolchain-funcs

DESCRIPTION="A dynamic library bundling the guest payload consumed by libkrun"
HOMEPAGE="https://github.com/containers/libkrunfw"

KERNEL_VERSION=linux-6.12.34

SRC_URI="
	https://cdn.kernel.org/pub/linux/kernel/v6.x/${KERNEL_VERSION}.tar.xz
	https://github.com/containers/libkrunfw/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

BDEPEND="
	app-alternatives/bc
	app-alternatives/cpio
	dev-build/make
	dev-lang/perl
	$(python_gen_any_dep '
		dev-python/pyelftools[${PYTHON_USEDEP}]
	')
	sys-devel/bison
	sys-devel/flex
	>=sys-libs/ncurses-5.2
	virtual/libelf
	virtual/pkgconfig
"

PATCHES="
	${FILESDIR}/${PN}-4.5.1-do-not-strip.patch
"

python_check_deps() {
	python_has_version "dev-python/pyelftools[${PYTHON_USEDEP}]"
}

src_unpack() {
	unpack "${P}.tar.gz"
}

src_compile() {
	unset ARCH
	emake PREFIX=/usr KERNEL_TARBALL="${DISTDIR}/${KERNEL_VERSION}.tar.xz" $(tc-is-clang && echo LLVM=1)
}

src_install() {
	emake DESTDIR="${D}" PREFIX=/usr install
}
