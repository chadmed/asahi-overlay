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
CONFIG_VER=6.6.3-414-gentoo
GENTOO_CONFIG_VER=g11

DESCRIPTION="Asahi Linux kernel sources"
HOMEPAGE="https://asahilinux.org"
KERNEL_URI="https://github.com/AsahiLinux/linux/archive/refs/tags/${MY_P}.tar.gz -> ${PN}-${PV}.tar.gz"
SRC_URI="${KERNEL_URI}
	https://github.com/projg2/gentoo-kernel-config/archive/${GENTOO_CONFIG_VER}.tar.gz
		-> gentoo-kernel-config-${GENTOO_CONFIG_VER}.tar.gz
	https://copr-dist-git.fedorainfracloud.org/cgit/@asahi/kernel/kernel.git/plain/kernel-aarch64-16k-fedora.config?id=be420b20d9a73b16a6ee7b6cdb34194efd89bb91
		-> kernel-aarch64-16k-fedora.config-${CONFIG_VER}
"

S="${WORKDIR}/linux-${MY_P}"

LICENSE="GPL-2"
KEYWORDS="arm64"

IUSE="debug"

# Rust is non-negotiable for the dist kernel
DEPEND="
	${DEPEND}
	virtual/rust
	|| (
		 ~dev-lang/rust-bin-1.75.0[rust-src,rustfmt]
		 dev-lang/rust:stable/1.75[rust-src,rustfmt]
	   )
	dev-util/bindgen
	debug? ( dev-util/pahole )
"

PDEPEND="
	~virtual/dist-kernel-${PV}
"

QA_FLAGS_IGNORED="
	usr/src/linux-.*/scripts/gcc-plugins/.*.so
	usr/src/linux-.*/vmlinux
	usr/src/linux-.*/arch/powerpc/kernel/vdso.*/vdso.*.so.dbg
"

PATCHES=(
		"${FILESDIR}/${P}-enable-speakers-stage1.patch"
		"${FILESDIR}/${P}-enable-speakers-stage2.patch"
		"${FILESDIR}/${P}-rust-alloc-fix.patch"
)

src_prepare() {
	default

	# prepare the default config
	cp "${DISTDIR}/kernel-aarch64-16k-fedora.config-${CONFIG_VER}" ".config" || die

	# ensure a consistant version across kernel and gentoo
	# this passes the ${PV}-as-release check in kernel-install_pkg_preinst()
	# override "-asahi" in localversion.05-asahi with "_pX" to override the
	# kernel's base varsion to gentoo's ${PV}
	echo "-p${MY_TAG}" > localversion.05-asahi
	# use CONFIG_LOCALVERSION to provide "asahi" and "dist" annotations.
	local myversion="-asahi-dist"
	echo "CONFIG_LOCALVERSION=\"${myversion}\"" > "${T}"/version.config || die
	local dist_conf_path="${WORKDIR}/gentoo-kernel-config-${GENTOO_CONFIG_VER}"

	local merge_configs=(
		"${T}"/version.config
		"${dist_conf_path}"/base.config
	)
	use debug || merge_configs+=(
		"${dist_conf_path}"/no-debug.config
	)

	# deselect all non APPLE arm64 ARCHs
	merge_configs+=(
		"${FILESDIR}"/linux-$(ver_cut 1-2)_arm64_deselect_non_apple_arch.config
	)
	# adjust base config for Apple silicon systems
	merge_configs+=(
		"${FILESDIR}"/linux-$(ver_cut 1-2)_arch_apple_overrides.config
	)

	kernel-build_merge_configs "${merge_configs[@]}"
}

src_install() {
	# call kernel-build's scr_install
	kernel-build_src_install

	# symlink installed *.dtbs back into kernel "source" directory
	local dir_ver=${PV}${KV_LOCALVERSION}
	local kernel_dir=/usr/src/linux-${dir_ver}
	local relfile=${ED}${kernel_dir}/include/config/kernel.release
	local module_ver
	module_ver=$(<"${relfile}") || die

	for dtb in /boot/dtbs/${module_ver}/apple/*.dtb; do
		dosym ${dtb} /${kernel_dir}/arch/arm64/boot/dts/apple/$(basename ${dtb})
	done
}

pkg_postinst() {
	einfo "For more information about Asahi Linux please visit ${HOMEPAGE},"
	einfo "or consult the Wiki at https://github.com/AsahiLinux/docs/wiki."
	kernel-build_pkg_postinst
}
