# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# I NEED to find a way to automate finding needed crates (`cargo install` did not work well)
CRATES="
annotate-snippets-0.9.1
unicode-width-0.1.10
yansi-term-0.1.2
bitflags-1.3.2
cexpr-0.6.0
nom-7.1.3
memchr-2.5.0
minimal-lexical-0.2.1
clang-sys-1.4.0
glob-0.3.1
libc-0.2.139
libloading-0.7.4
cfg-if-1.0.0
lazy_static-1.4.0
lazycell-1.3.0
log-0.4.17
cfg-if-1.0.0
peeking_take_while-0.1.2
prettyplease-0.2.0
proc-macro2-1.0.52
unicode-ident-1.0.6
syn-2.0.7
proc-macro2-1.0.52
quote-1.0.26
proc-macro2-1.0.52
unicode-ident-1.0.6
proc-macro2-1.0.52
quote-1.0.26
regex-1.7.1
aho-corasick-0.7.20
memchr-2.5.0
memchr-2.5.0
regex-syntax-0.6.28
rustc-hash-1.1.0
shlex-1.1.0
syn-2.0.7
which-4.4.0
either-1.8.1
libc-0.2.139
clap-4.1.4
bitflags-1.3.2
clap_derive-4.1.0
heck-0.4.0
proc-macro-error-1.0.4
proc-macro-error-attr-1.0.4
proc-macro2-1.0.52
quote-1.0.26
version_check-0.9.4
proc-macro2-1.0.52
quote-1.0.26
syn-1.0.107
proc-macro2-1.0.52
quote-1.0.26
unicode-ident-1.0.6
version_check-0.9.4
proc-macro2-1.0.52
quote-1.0.26
syn-1.0.107
clap_lex-0.3.1
os_str_bytes-6.4.1
is-terminal-0.4.2
io-lifetimes-1.0.4
libc-0.2.139
rustix-0.36.7
bitflags-1.3.2
io-lifetimes-1.0.4
libc-0.2.139
linux-raw-sys-0.1.4
once_cell-1.17.0
strsim-0.10.0
termcolor-1.2.0
env_logger-0.10.0
env_logger-0.8.4
humantime-2.1.0
is-terminal-0.4.2
log-0.4.17
regex-1.7.1
termcolor-1.2.0
log-0.4.17
shlex-1.1.0
cc-1.0.78
diff-0.1.13
tempfile-3.4.0
quickcheck-1.0.3
block-0.1.6
objc-0.2.7
fastrand-1.8.0
redox_syscall-0.2.16
windows-sys-0.42.0
rand-0.8.5
winapi-0.3.9
malloc_buf-0.0.6
hermit-abi-0.2.6
winapi-util-0.1.5
instant-0.1.12
errno-0.2.8
windows_aarch64_gnullvm-0.42.1
windows_aarch64_msvc-0.42.1
windows_i686_gnu-0.42.1
windows_i686_msvc-0.42.1
windows_x86_64_gnu-0.42.1
windows_x86_64_gnullvm-0.42.1
windows_x86_64_msvc-0.42.1
rand_core-0.6.4
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
errno-dragonfly-0.1.2
getrandom-0.2.8
wasi-0.11.0+wasi-snapshot-preview1
"

inherit rust-toolchain cargo

DESCRIPTION="Automatically generates Rust FFI bindings to C (and some C++) libraries"
HOMEPAGE="https://rust-lang.github.io/rust-bindgen"
SRC_URI="https://github.com/rust-lang/rust-${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris)"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="virtual/rust[rustfmt]"
RDEPEND="${DEPEND}
	sys-devel/clang:="

QA_FLAGS_IGNORED="usr/bin/bindgen"

S="${WORKDIR}/rust-${P}"

src_test () {
	# required by clang during tests
	local -x TARGET="$(rust_abi)"

	cargo_src_test --bins --lib
}

src_install () {
	cargo_src_install --path "${S}/bindgen-cli"

	einstalldocs
}
