# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	ansi_term@0.11.0
	arrayref@0.3.6
	arrayvec@0.5.2
	atty@0.2.14
	autocfg@1.0.1
	base64@0.13.0
	bitflags@1.2.1
	blake2b_simd@0.5.11
	cfg-if@0.1.10
	cfg-if@1.0.0
	clap@2.33.3
	confy@0.4.0
	constant_time_eq@0.1.5
	crossbeam-utils@0.8.3
	directories@2.0.2
	dirs-sys@0.3.5
	getrandom@0.1.16
	hermit-abi@0.1.18
	lazy_static@1.4.0
	libc@0.2.90
	proc-macro2@1.0.24
	quote@1.0.9
	redox_syscall@0.1.57
	redox_users@0.3.5
	rust-argon2@0.8.3
	serde@1.0.124
	serde_derive@1.0.124
	strsim@0.8.0
	syn@1.0.64
	text_io@0.1.8
	textwrap@0.11.0
	toml@0.5.8
	unicode-width@0.1.8
	unicode-xid@0.2.1
	vec_map@0.8.2
	wasi@0.9.0+wasi-snapshot-preview1
	winapi@0.3.9
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-x86_64-pc-windows-gnu@0.4.0
"

inherit cargo

DESCRIPTION="Create microVMs from OCI images"
HOMEPAGE="https://github.com/containers/krunvm"
SRC_URI="${CARGO_CRATE_URIS}
	https://github.com/containers/krunvm/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~arm64"

DEPEND="
	>=virtual/rust-1.74.0
	>=dev-libs/libkrun-1.6.0
	app-containers/buildah
	dev-ruby/asciidoctor
"
RDEPEND="${DEPEND}"

src_compile() {
	emake
}

src_install() {
	emake PREFIX="${D}/usr" install
}
