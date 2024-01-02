# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	adler@1.0.2
	ahash@0.8.2
	aho-corasick@0.7.18
	alsa@0.7.1
	alsa-sys@0.3.1
	anstream@0.6.5
	anstyle@1.0.4
	anstyle-parse@0.2.3
	anstyle-query@1.0.2
	anstyle-wincon@3.0.2
	anyhow@1.0.75
	atty@0.2.14
	autocfg@1.0.1
	bincode@1.3.3
	bindgen@0.66.1
	bitfield@0.13.2
	bitflags@1.3.2
	bitflags@2.4.0
	byteorder@1.4.3
	cc@1.0.70
	cexpr@0.6.0
	cfg-expr@0.11.0
	cfg-if@1.0.0
	chrono@0.4.19
	clang-sys@1.6.1
	clap@4.4.11
	clap_builder@4.4.11
	clap_derive@4.4.7
	clap_lex@0.6.0
	codicon@3.0.0
	colorchoice@1.0.0
	convert_case@0.6.0
	cookie-factory@0.3.2
	crc32fast@1.2.1
	crossbeam-channel@0.5.6
	crossbeam-utils@0.8.11
	curl@0.4.44
	curl-sys@0.4.56+curl-7.83.1
	dirs@4.0.0
	dirs-sys@0.3.6
	env_logger@0.9.0
	flate2@1.0.21
	foreign-types@0.3.2
	foreign-types-shared@0.1.1
	getrandom@0.2.3
	glob@0.3.1
	hashbrown@0.13.2
	heck@0.4.1
	hermit-abi@0.1.19
	hex@0.4.3
	humantime@2.1.0
	iocuddle@0.1.1
	itoa@0.4.8
	kbs-types@0.2.0
	kvm-bindings@0.6.0
	kvm-ioctls@0.12.0
	lazy_static@1.4.0
	lazycell@1.3.0
	libc@0.2.147
	libloading@0.7.4
	libz-sys@1.1.8
	log@0.4.14
	lru@0.9.0
	memchr@2.4.1
	memoffset@0.7.1
	minimal-lexical@0.2.1
	miniz_oxide@0.4.4
	nix@0.24.3
	nix@0.26.2
	nom@7.1.3
	num-integer@0.1.44
	num-traits@0.2.14
	once_cell@1.17.0
	openssl@0.10.36
	openssl-probe@0.1.5
	openssl-sys@0.9.66
	peeking_take_while@0.1.2
	pin-utils@0.1.0
	pkg-config@0.3.19
	ppv-lite86@0.2.10
	proc-macro2@1.0.67
	procfs@0.12.0
	quote@1.0.33
	rand@0.8.5
	rand_chacha@0.3.1
	rand_core@0.6.3
	redox_syscall@0.2.10
	redox_users@0.4.0
	regex@1.5.6
	regex-syntax@0.6.26
	remain@0.2.11
	rustc-hash@1.1.0
	ryu@1.0.5
	schannel@0.1.20
	serde@1.0.130
	serde-big-array@0.4.1
	serde_bytes@0.11.5
	serde_derive@1.0.130
	serde_json@1.0.67
	sev@1.1.0
	shlex@1.2.0
	smallvec@1.11.1
	socket2@0.4.4
	static_assertions@1.1.0
	strsim@0.10.0
	syn@1.0.76
	syn@2.0.37
	system-deps@6.0.3
	termcolor@1.1.3
	thiserror@1.0.47
	thiserror-impl@1.0.47
	time@0.1.43
	toml@0.5.11
	unicode-ident@1.0.11
	unicode-segmentation@1.10.1
	unicode-xid@0.2.2
	utf8parse@0.2.1
	uuid@1.3.0
	vcpkg@0.2.15
	version-compare@0.1.1
	version_check@0.9.4
	virtio-bindings@0.2.0
	vm-fdt@0.2.0
	vm-memory@0.8.0
	vmm-sys-util@0.11.0
	wasi@0.10.2+wasi-snapshot-preview1
	winapi@0.3.9
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.5
	winapi-x86_64-pc-windows-gnu@0.4.0
	windows-sys@0.36.1
	windows-sys@0.52.0
	windows-targets@0.52.0
	windows_aarch64_gnullvm@0.52.0
	windows_aarch64_msvc@0.36.1
	windows_aarch64_msvc@0.52.0
	windows_i686_gnu@0.36.1
	windows_i686_gnu@0.52.0
	windows_i686_msvc@0.36.1
	windows_i686_msvc@0.52.0
	windows_x86_64_gnu@0.36.1
	windows_x86_64_gnu@0.52.0
	windows_x86_64_gnullvm@0.52.0
	windows_x86_64_msvc@0.36.1
	windows_x86_64_msvc@0.52.0
	zerocopy@0.6.3
	zerocopy-derive@0.6.3
"

inherit cargo

DESCRIPTION="Lightweight VMM enabling virt-based process isolation"
HOMEPAGE="https://github.com/containers/libkrun"
SRC_URI="
	https://github.com/slp/libkrun/archive/2f3a8c81b5e0d1a53498373bcd31836e14ef8577.tar.gz -> ${P}.tar.gz
	https://gitlab.freedesktop.org/pipewire/pipewire-rs/-/archive/068f16e4bcc2a58657ceb53bd134acb5b00a5391/pipewire-rs-068f16e4bcc2a58657ceb53bd134acb5b00a5391.tar.gz
	${CARGO_CRATE_URIS}
"

S="${WORKDIR}/${PN}-2f3a8c81b5e0d1a53498373bcd31836e14ef8577"

IUSE="+gpu +net"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~arm64"

RDEPEND="
	>=sys-firmware/libkrunfw-4.0.0
	>=media-video/pipewire-1.0.0
"
DEPEND="${RDEPEND}
	gpu? ( >=media-libs/virglrenderer-0.10.4-r1[native-context] )
"
BDEPEND="
	>=virtual/rust-1.74.0
	>=dev-util/patchelf-0.18.0
	>=sys-firmware/libkrunfw-4.0.0
"

PATCHES=(
	"${FILESDIR}/pipewire-crate.patch"
)

src_unpack() {
	cargo_src_unpack
	mv "pipewire-rs-068f16e4bcc2a58657ceb53bd134acb5b00a5391" "${S}/src/pipewire-rs"
}

src_compile() {
	local lkrun_modules
	use gpu && lkrun_modules="${lkrun_modules} --features gpu "
	use net && lkrun_modules="${lkrun_modules} --features net "
	emake FEATURE_FLAGS="${lkrun_modules}"
}

src_install() {
	emake PREFIX="${D}/usr/" install
}
