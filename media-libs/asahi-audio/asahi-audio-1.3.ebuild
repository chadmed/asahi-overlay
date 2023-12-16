# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Pipewire/Wireplumber configuration files for Apple Silicon"
HOMEPAGE="https://github.com/AsahiLinux/asahi-audio"
SRC_URI="https://github.com/AsahiLinux/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
LICENSE="MIT"
SLOT="0"

KEYWORDS="arm64"

RDEPEND="
	>=media-video/pipewire-0.3.85[extra,lv2,sound-server]
	>=media-video/wireplumber-0.4.17
	>=sys-kernel/asahi-sources-6.6.0_p11
	>=media-libs/alsa-ucm-conf-asahi-5.0
	media-libs/lsp-plugins[lv2]
	>=media-libs/bankstown-lv2-1.0.3
	sys-apps/speakersafetyd
"
DEPEND="${RDEPEND}"
