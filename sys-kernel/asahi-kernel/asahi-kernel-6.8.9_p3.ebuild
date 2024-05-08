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
	if [[ "$(ver_cut 3)" == "0" ]] ; then
		MY_P="asahi-$(ver_cut 1-2)-${MY_TAG}"
	else
		MY_P="asahi-$(ver_cut 1-3)-${MY_TAG}"
	fi
fi
CONFIG_VER=6.8.9-402-gentoo
GENTOO_CONFIG_VER=g11
FEDORA_CONFIG_DISTGIT="copr-dist-git.fedorainfracloud.org/cgit/@asahi/kernel"
# FEDORA_CONFIG_DISTGIT="copr-dist-git.fedorainfracloud.org/cgit/ngompa/fedora-asahi-dev"
FEDORA_CONFIG_SHA1=82a221a3043efc2022d39f532e13535f183661ca

DESCRIPTION="Asahi Linux kernel sources"
HOMEPAGE="https://asahilinux.org"
KERNEL_URI="https://github.com/AsahiLinux/linux/archive/refs/tags/${MY_P}.tar.gz -> linux-${MY_P}.tar.gz"
SRC_URI="${KERNEL_URI}
	https://github.com/projg2/gentoo-kernel-config/archive/${GENTOO_CONFIG_VER}.tar.gz
		-> gentoo-kernel-config-${GENTOO_CONFIG_VER}.tar.gz
	https://${FEDORA_CONFIG_DISTGIT}/kernel.git/plain/kernel-aarch64-16k-fedora.config?id=${FEDORA_CONFIG_SHA1}
		-> kernel-aarch64-16k-fedora.config-${CONFIG_VER}
"

S="${WORKDIR}/linux-${MY_P}"

LICENSE="GPL-2"
KEYWORDS="~arm64"

IUSE="debug"

# Rust is non-negotiable for the dist kernel
DEPEND="
	${DEPEND}
	virtual/rust
	|| (
			>=dev-lang/rust-bin-1.76[rust-src,rustfmt]
			>=dev-lang/rust-1.76[rust-src,rustfmt]
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
		"${FILESDIR}/${PN}-$(ver_cut 1-2)-enable-speakers.patch"
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
