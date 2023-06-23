# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
aho-corasick-1.0.2
android-tzdata-0.1.1
android_system_properties-0.1.5
anstream-0.3.2
anstyle-1.0.0
anstyle-parse-0.2.0
anstyle-query-1.0.0
anstyle-wincon-1.0.1
anyhow-1.0.71
approx-0.5.1
autocfg-1.1.0
bitflags-1.3.2
block-0.1.6
bumpalo-3.13.0
bytemuck-1.13.1
bytemuck_derive-1.4.1
byteorder-1.4.3
cairo-rs-0.17.10
cairo-sys-rs-0.17.10
cast-0.3.0
cc-1.0.79
cfg-expr-0.15.2
cfg-if-1.0.0
chrono-0.4.26
clap-4.3.5
clap_builder-4.3.5
clap_complete-4.3.1
clap_derive-4.3.2
clap_lex-0.5.0
colorchoice-1.0.0
convert_case-0.4.0
core-foundation-sys-0.8.4
crossbeam-channel-0.5.8
crossbeam-deque-0.8.3
crossbeam-epoch-0.9.15
crossbeam-utils-0.8.16
cssparser-0.29.6
cssparser-macros-0.6.1
data-url-0.2.0
derive_more-0.99.17
drm-0.9.0
drm-ffi-0.5.0
drm-fourcc-2.2.0
drm-sys-0.4.0
dtoa-1.0.6
dtoa-short-0.3.4
either-1.8.1
encoding-0.2.33
encoding-index-japanese-1.20141219.5
encoding-index-korean-1.20141219.5
encoding-index-simpchinese-1.20141219.5
encoding-index-singlebyte-1.20141219.5
encoding-index-tradchinese-1.20141219.5
encoding_index_tests-0.1.4
errno-0.3.1
errno-dragonfly-0.1.2
float-cmp-0.9.0
form_urlencoded-1.2.0
futf-0.1.5
futures-channel-0.3.28
futures-core-0.3.28
futures-executor-0.3.28
futures-io-0.3.28
futures-macro-0.3.28
futures-task-0.3.28
futures-util-0.3.28
fxhash-0.2.1
gdk-pixbuf-0.17.10
gdk-pixbuf-sys-0.17.10
getrandom-0.1.16
getrandom-0.2.10
gio-0.17.10
gio-sys-0.17.10
glib-0.17.10
glib-macros-0.17.10
glib-sys-0.17.10
gobject-sys-0.17.10
hashbrown-0.12.3
heck-0.4.1
hermit-abi-0.2.6
hermit-abi-0.3.1
iana-time-zone-0.1.57
iana-time-zone-haiku-0.1.2
idna-0.4.0
indexmap-1.9.3
input-0.8.2
input-linux-0.6.0
input-linux-sys-0.8.0
input-sys-1.17.0
io-lifetimes-1.0.11
is-terminal-0.4.7
itertools-0.10.5
itoa-1.0.6
js-sys-0.3.64
language-tags-0.3.2
lazy_static-1.4.0
libc-0.2.146
libudev-sys-0.1.4
linux-raw-sys-0.3.8
locale_config-0.3.0
lock_api-0.4.10
log-0.4.19
mac-0.1.1
malloc_buf-0.0.6
markup5ever-0.11.0
matches-0.1.10
matrixmultiply-0.3.7
memchr-2.5.0
memoffset-0.7.1
memoffset-0.9.0
nalgebra-0.32.2
nalgebra-macros-0.2.0
new_debug_unreachable-1.0.4
nix-0.26.2
nodrop-0.1.14
num-complex-0.4.3
num-integer-0.1.45
num-rational-0.4.1
num-traits-0.2.15
num_cpus-1.15.0
objc-0.2.7
objc-foundation-0.1.1
objc_id-0.1.1
once_cell-1.18.0
pango-0.17.10
pango-sys-0.17.10
pangocairo-0.17.10
pangocairo-sys-0.17.10
parking_lot-0.12.1
parking_lot_core-0.9.8
paste-1.0.12
percent-encoding-2.3.0
phf-0.8.0
phf-0.10.1
phf_codegen-0.8.0
phf_codegen-0.10.0
phf_generator-0.8.0
phf_generator-0.10.0
phf_macros-0.10.0
phf_shared-0.8.0
phf_shared-0.10.0
pin-project-lite-0.2.9
pin-utils-0.1.0
pkg-config-0.3.27
ppv-lite86-0.2.17
precomputed-hash-0.1.1
privdrop-0.5.3
proc-macro-crate-1.3.1
proc-macro-error-1.0.4
proc-macro-error-attr-1.0.4
proc-macro-hack-0.5.20+deprecated
proc-macro2-1.0.60
quote-1.0.28
rand-0.7.3
rand-0.8.5
rand_chacha-0.2.2
rand_chacha-0.3.1
rand_core-0.5.1
rand_core-0.6.4
rand_hc-0.2.0
rand_pcg-0.2.1
rawpointer-0.2.1
rayon-1.7.0
rayon-core-1.11.0
rctree-0.5.0
redox_syscall-0.3.5
regex-1.8.4
regex-syntax-0.7.2
rgb-0.8.36
rustc_version-0.4.0
rustix-0.37.20
safe_arch-0.7.0
scopeguard-1.1.0
selectors-0.24.0
semver-1.0.17
serde-1.0.164
serde_spanned-0.6.2
servo_arc-0.2.0
simba-0.8.1
siphasher-0.3.10
slab-0.4.8
smallvec-1.10.0
stable_deref_trait-1.2.0
static_assertions-1.1.0
string_cache-0.8.7
string_cache_codegen-0.5.2
strsim-0.10.0
syn-1.0.109
syn-2.0.18
system-deps-6.1.0
target-lexicon-0.12.7
tendril-0.4.3
thiserror-1.0.40
thiserror-impl-1.0.40
tinyvec-1.6.0
tinyvec_macros-0.1.1
toml-0.7.4
toml_datetime-0.6.2
toml_edit-0.19.10
typenum-1.16.0
udev-0.7.0
unicode-bidi-0.3.13
unicode-ident-1.0.9
unicode-normalization-0.1.22
url-2.4.0
utf-8-0.7.6
utf8parse-0.2.1
version-compare-0.1.1
version_check-0.9.4
wasi-0.9.0+wasi-snapshot-preview1
wasi-0.11.0+wasi-snapshot-preview1
wasm-bindgen-0.2.87
wasm-bindgen-backend-0.2.87
wasm-bindgen-macro-0.2.87
wasm-bindgen-macro-support-0.2.87
wasm-bindgen-shared-0.2.87
wide-0.7.10
winapi-0.3.9
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
windows-0.48.0
windows-sys-0.48.0
windows-targets-0.48.0
windows_aarch64_gnullvm-0.48.0
windows_aarch64_msvc-0.48.0
windows_i686_gnu-0.48.0
windows_i686_msvc-0.48.0
windows_x86_64_gnu-0.48.0
windows_x86_64_gnullvm-0.48.0
windows_x86_64_msvc-0.48.0
winnow-0.4.7
xml5ever-0.17.0
"

LIBRSVG_COMMIT="b831e077174ae608d8cd09e532fc0e7ce1fe5c4f"

declare -A GIT_CRATES=(
	[librsvg]="https://gitlab.gnome.org/GNOME/librsvg;${LIBRSVG_COMMIT}"
)

inherit cargo udev systemd linux-info

DESCRIPTION="The most basic dynamic function row daemon possible"
HOMEPAGE="https://github.com/WhatAmISupposedToPutHere/tiny-dfr"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~arm64"

IUSE="systemd"

SRC_URI="
	$(cargo_crate_uris)
	https://gitlab.gnome.org/GNOME/librsvg/-/archive/2.56.0/librsvg-2.56.0.tar.gz -> librsvg-2.56.0.crate
	https://github.com/WhatAmISupposedToPutHere/tiny-dfr/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
"

DEPEND="
	dev-libs/libinput
	x11-libs/pango
"

RDEPEND="${DEPEND}"

pkg_pretend() {
	local CONFIG_CHECK="~INPUT_UINPUT"
	[[ ${MERGE_TYPE} != buildonly ]] && check_extra_config
}

src_install() {
	cargo_src_install

	insinto /usr/share/tiny-dfr
	doins share/tiny-dfr/*

	udev_dorules etc/udev/rules.d/*
	use systemd && systemd_dounit etc/systemd/system/tiny-dfr.service
	use systemd && systemd_newunit /dev/null 'systemd-backlight@backlight:228200000.display-pipe.0.service'
	use systemd || newinitd "${FILESDIR}"/${PN}.initd ${PN}
}
