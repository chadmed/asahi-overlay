# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
K_SECURITY_UNSUPPORTED="1"
ETYPE="sources"
#K_WANT_GENPATCHES="base extras experimental"
#K_GENPATCHES_VER="5"
K_NODRYRUN="1"

inherit kernel-build

if [[ ${PV} != ${PV/_rc} ]] ; then
	# $PV is expected to be of following form: 6.0_rc5_p1
	MY_TAG="$(ver_cut 6)"
	MY_P="asahi-$(ver_rs 2 - $(ver_cut 1-4))-${MY_TAG}"
else
	# $PV is expected to be of following form: 5.19.0_p1
	MY_TAG="$(ver_cut 5)"
	MY_P="asahi-$(ver_cut 1-2)-${MY_TAG}"
fi

DESCRIPTION="Asahi Linux kernel sources"
HOMEPAGE="https://asahilinux.org"
KERNEL_URI="https://github.com/AsahiLinux/linux/archive/refs/tags/${MY_P}.tar.gz -> ${PN}-${PV}.tar.gz"
SRC_URI="${KERNEL_URI}
	https://raw.githubusercontent.com/AsahiLinux/PKGBUILDs/main/linux-asahi/config
	https://raw.githubusercontent.com/AsahiLinux/PKGBUILDs/main/linux-asahi/config.edge
"

S="${WORKDIR}/linux-${MY_P}"

LICENSE="GPL-2"
KEYWORDS="arm64"

IUSE="debug"

# Rust is non-negotiable for the dist kernel
DEPEND="
	${DEPEND}
	|| ( >=dev-lang/rust-1.72.0[rust-src,rustfmt]
		 >=dev-lang/rust-bin-1.72.0[rust-src,rustfmt]
	   )
	dev-util/bindgen
"

PDEPEND="
	=virtual/dist-kernel-${PV}
"

PATCHES=(
		"${FILESDIR}/${P}-enable-speakers-stage1.patch"
		"${FILESDIR}/${P}-enable-speakers-stage2.patch"
		"${FILESDIR}/${P}-rust-alloc-fix.patch"
)

src_prepare() {
	default
	echo "-${MY_TAG}-dist" > localversion.10-pkgrel || die
	cp "${DISTDIR}/config" ".config" || die
	kernel-build_merge_configs "${DISTDIR}/config.edge"
	echo 'CONFIG_LOCALVERSION=""' > "${T}/fakeversion.config"
	kernel-build_merge_configs "${T}/fakeversion.config"
}

# Override kernel-install_pkg_preinst() to avoid ${PV}-as-release check
pkg_preinst() {
	true
}

pkg_postinst() {
	einfo "For more information about Asahi Linux please visit ${HOMEPAGE},"
	einfo "or consult the Wiki at https://github.com/AsahiLinux/docs/wiki."
	kernel-build_pkg_postinst
}
