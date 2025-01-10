# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Metapackage for the Asahi support packages"
HOMEPAGE="https://asahilinux.org/"

LICENSE="metapackage"
SLOT=0
KEYWORDS="arm64"
IUSE="+mesa sound +sources kde kernel"

REQUIRED_USE="
	sources? ( !kernel )
	kernel? ( !sources )
"

RDEPEND="
	sys-boot/m1n1
	sys-boot/u-boot
	sys-apps/asahi-scripts
	sys-apps/asahi-configs
	sys-firmware/asahi-firmware
	kernel? ( sys-kernel/asahi-kernel )
	sources? ( sys-kernel/asahi-sources )
	media-libs/alsa-ucm-conf-asahi
	sound? ( media-libs/asahi-audio )
	mesa? (
		>=media-libs/mesa-24.1.0_pre20240228[video_cards_asahi(-)]
		kernel? ( >=sys-kernel/asahi-kernel-6.6.0_p15 )
		sources? ( >=sys-kernel/asahi-sources-6.6.0_p15 )
	)
	kde? ( kde-plasma/kwin[filecaps] )
"
