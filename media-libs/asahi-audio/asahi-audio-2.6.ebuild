# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="PipeWire/WirePlumber configuration files for Apple Silicon"
HOMEPAGE="https://github.com/AsahiLinux/asahi-audio"
SRC_URI="https://github.com/AsahiLinux/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
LICENSE="MIT"
SLOT="0/2.0"

KEYWORDS="~arm64"

RDEPEND="
	>=media-video/pipewire-1.0.2[extra,lv2,sound-server]
	>=media-video/wireplumber-0.5.2
	|| (
		>=sys-kernel/asahi-sources-6.6.0_p11:*
		>=virtual/dist-kernel-6.6.0_p11:asahi
	   )
	>=media-libs/alsa-ucm-conf-asahi-5.0
	>=media-libs/lsp-plugins-1.2.6[lv2]
	>=media-libs/bankstown-lv2-1.1.0
	sys-apps/speakersafetyd
"
DEPEND="
	${RDEPEND}
"
