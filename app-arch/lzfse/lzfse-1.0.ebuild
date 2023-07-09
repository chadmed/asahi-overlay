# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CMAKE_MAKEFILE_GENERATOR="emake"
CMAKE_INSTALL_PREFIX=""

inherit cmake

DESCRIPTION="LZFSE compression utilities"
HOMEPAGE="https://github.com/lzfse/lzfse"
SRC_URI="https://github.com/lzfse/lzfse/archive/refs/tags/lzfse-${PV}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="arm64"
S="${WORKDIR}/${PN}-lzfse-${PV}"

src_configure() {
	cmake_src_configure
}

src_compile() {
	cmake_src_compile
}

src_install() {
	cmake_src_install
}
