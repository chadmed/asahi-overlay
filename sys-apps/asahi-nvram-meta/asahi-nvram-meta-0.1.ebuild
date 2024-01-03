# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Metapackage for asahi-nvram modules"
HOMEPAGE="https://github.com/WhatAmISupposedToPutHere/asahi-nvram"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~arm64"
IUSE="+bless bluetooth raw wifi"

RDEPEND="
	bless? ( sys-apps/asahi-bless )
	bluetooth? ( net-misc/asahi-btsync )
	raw? ( sys-apps/asahi-nvram )
	wifi? ( net-misc/asahi-wifisync )
"
