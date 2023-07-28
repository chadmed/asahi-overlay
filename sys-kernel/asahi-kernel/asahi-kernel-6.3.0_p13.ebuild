# Copyright 2020-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit kernel-build toolchain-funcs

MY_TAG="$(ver_cut 5)"
MY_P="asahi-$(ver_cut 1-2)-${MY_TAG}"

DESCRIPTION="Build downstream Asahi Linux"
HOMEPAGE="https://asahilinux.org"
LICENSE="GPL-2"
SRC_URI+="
https://github.com/AsahiLinux/linux/archive/refs/tags/${MY_P}.tar.gz
https://raw.githubusercontent.com/AsahiLinux/PKGBUILDs/main/linux-asahi/config
https://raw.githubusercontent.com/AsahiLinux/PKGBUILDs/main/linux-asahi/config.edge
"
S=${WORKDIR}/linux-${MY_P}

PATCHES=(
	"${FILESDIR}"/rust_is_available.patch
)

KEYWORDS="arm64"
IUSE="debug experimental"

# NOTE: the two rust version configurations are the ones that I have tested:
# * (clang as cc) llvm-16 + rust-1.70 + bindgen-0.65.1 + bindgen patch
# * (clang as cc) llvm-15 + rust-1.69 + bindgen-0.56.0
# I'm sure there are a lot more that could work

#	debug? ( dev-util/pahole )
BDEPEND="
	experimental? (
		|| (
			(
				virtual/rust:0/llvm-16
				=dev-util/bindgen-0.65.1
			)
			(
				virtual/rust:0/llvm-15
				=dev-util/bindgen-0.56.0
			)
		)
		|| ( dev-lang/rust[rust-src] dev-lang/rust-bin[rust-src] )
	)
"

src_unpack() {
	unpack ${MY_P}.tar.gz
}

src_prepare() {
	# Is there an easy way to get the tag of a satisfied dependency?
	# (see whether the 0/llvm-16 or 0/llvm-15 rust was installed)
	# right now just using clang version as placeholder for llvm version until I figure that out
	[ $(clang-major-version) == 16 ] && PATCHES+=("${FILESDIR}"/bindgen.patch)

	default

	cp "${DISTDIR}/config" .config || die

	local myversion="-${MY_TAG}-dist"
	use experimental && myversion+="-edge"
	echo "CONFIG_LOCALVERSION=\"${myversion}\"" > "${T}"/version.config || die

	local merge_configs=()
	use experimental && merge_configs+=("${DISTDIR}/config.edge")

	# needs to be merged after config.edge, so that it overrides the version
	merge_configs+=("${T}"/version.config)

	kernel-build_merge_configs "${merge_configs[@]}"
}

# NOTE: `default` doesn't seem to call the kernel-build src_configure
src_configure() {
	# sanity check for testing: maybe remove once BDEPS is sorted out
	# it would be nice to run emake with the MAKEARGS from kernel-build  ...
	use experimental && emake rustavailable || die
	kernel-build_src_configure
}

# TODO: look into QA pre-stripped warnings
# they look like files that should not be installed anyway
# maybe do a `make clean` before the sources are installed
# (though that might require a kernel-build eclass change)
# FILES (for reference):
# * arch/arm64/kernel/vdso/vdso.so
# * scripts/sorttable
# * scripts/kallsyms
# * scripts/kconfig/conf
# * scripts/basic/fixdep
# * scripts/asn1_compiler
# * rust/libmacros.so
# * arch/arm64/kernel/vdso/vdso.so.dbg
# * scripts/generate_rust_target
# * scripts/dtc/fdtoverlay
# * scripts/mod/mk_elfconfig
# * scripts/dtc/dtc
# * scripts/mod/modpost

# NOTE: this is for bypassing kernel-install version checking stuff
# it wants kernel version to be: ${PV} (so x.x.x_p$tag*)
# asahi-sources looks like this: (x.x.x-$tag*)
# PROS:
# * same versioning scheme as upstream asahi-overlay
# CONS:
# * bypassing upstream gentoo eclasses is kind of iffy
# * misses the rest of kernel-install_pkg_preinst
# 	- (adjusting symlinks for merged-usr)
pkg_preinst() {
	echo "tests"
}
