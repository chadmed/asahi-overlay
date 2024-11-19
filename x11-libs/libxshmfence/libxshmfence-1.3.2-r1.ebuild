# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

XORG_MULTILIB=yes
XORG_TARBALL_SUFFIX="xz"
inherit xorg-3

DESCRIPTION="Shared memory fences using futexes"

KEYWORDS="~arm64"

DEPEND="x11-base/xorg-proto"

PATCHES="
	${FILESDIR}/${P}-memfd-envvar.patch
"
