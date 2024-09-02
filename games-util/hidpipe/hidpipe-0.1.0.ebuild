# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	acl-sys@1.2.2
	autocfg@1.3.0
	bitflags@2.6.0
	cfg-if@1.0.0
	cfg_aliases@0.2.1
	hermit-abi@0.3.9
	input-linux@0.7.0
	input-linux-sys@0.9.0
	io-lifetimes@1.0.11
	libc@0.2.155
	libudev-sys@0.1.4
	memoffset@0.9.1
	nix@0.29.0
	pkg-config@0.3.30
	posix-acl@1.2.0
	udev@0.8.0
	windows-sys@0.48.0
	windows-targets@0.48.5
	windows_aarch64_gnullvm@0.48.5
	windows_aarch64_msvc@0.48.5
	windows_i686_gnu@0.48.5
	windows_i686_msvc@0.48.5
	windows_x86_64_gnu@0.48.5
	windows_x86_64_gnullvm@0.48.5
	windows_x86_64_msvc@0.48.5
"

inherit cargo systemd

DESCRIPTION="Pass hid devices to micro vms."
HOMEPAGE="https://github.com/WhatAmISupposedToPutHere/hidpipe"
SRC_URI="
	https://github.com/WhatAmISupposedToPutHere/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"

LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions LGPL-2.1 MIT"
SLOT="0"
KEYWORDS="~arm64"

DEPEND="
	sys-apps/acl
	virtual/udev
"
RDEPEND="${DEPEND}"

QA_FLAGS_IGNORED="usr/bin/${PN}-client usr/bin/${PN}-server"

src_compile() {
	cargo_src_compile --workspace
}

src_install() {
	local bin
	for bin in hidpipe-{client,server}; do
		dobin "$(cargo_target_dir)/$bin"
	done

	systemd_douserunit etc/systemd/user/*
}
