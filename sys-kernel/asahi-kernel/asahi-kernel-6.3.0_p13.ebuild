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
	sys-apps/asahi-scripts
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

	MYVERSION="-${MY_TAG}-dist$(use experimental && echo "-edge")"
	echo "CONFIG_LOCALVERSION=\"${MYVERSION}\"" > "${T}"/version.config || die
	KV_LOCALVERSION="-asahi-dist$(use experimental && echo "-edge")"

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

src_install() {
	# install dtbs for `update-m1n1`
	local kernel_dir=/usr/src/linux-${PV}${KV_LOCALVERSION}
	insinto ${kernel_dir}/arch/arm64/boot/dts/apple/
	doins "${WORKDIR}"/build/arch/arm64/boot/dts/apple/*.dtb

	kernel-build_src_install
}

# NOTE: this is for bypassing kernel-install version checking stuff
# it wants kernel version to be: ${PV} (so x.x.x_p$tag*)
# asahi-sources looks like this: (x.x.x-$tag*)
pkg_preinst() {
	local release="$(ver_cut 1-3)-asahi${MYVERSION}"
	# code from kernel-install_pkg_preinst
	if [[ -L ${EROOT}/lib && ${EROOT}/lib -ef ${EROOT}/usr/lib ]]; then
		# Adjust symlinks for merged-usr.
		rm "${ED}/lib/modules/${release}"/{build,source} || die
		dosym "../../../src/linux-${PV}${KV_LOCALVERSION}" "/usr/lib/modules/${release}/build"
		dosym "../../../src/linux-${PV}${KV_LOCALVERSION}" "/usr/lib/modules/${release}/source"
	fi
}

pkg_postinst() {
	kernel-install_pkg_postinst

	update-m1n1
}
