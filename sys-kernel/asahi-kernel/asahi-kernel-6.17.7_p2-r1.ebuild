# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
K_SECURITY_UNSUPPORTED="1"
K_NODRYRUN="1"

#KERNEL_IUSE_GENERIC_UKI=1
KERNEL_IUSE_MODULES_SIGN=1

RUST_MIN_VER="1.85.0"
RUST_REQ_USE='rust-src,rustfmt'

inherit kernel-build rust toolchain-funcs verify-sig

BASE_P=linux-${PV%.*}
PATCH_PV=${PV%_p*}
PATCHSET=linux-gentoo-patches-6.17.2
# https://koji.fedoraproject.org/koji/packageinfo?packageID=8
# forked to https://github.com/projg2/fedora-kernel-config-for-gentoo
CONFIG_VER=6.17.3-gentoo
GENTOO_CONFIG_VER=g17
SHA256SUM_DATE=20251102

# asahi specific tag and version parsing
ASAHI_TAGV=${PV#*_p}
ASAHI_TAG="asahi-${PATCH_PV}-${ASAHI_TAGV}"
# BASE_ASAHI_TAG is the first used TAG of specific release, i.e. usually
# the first tag of a linux 6.x or linux stable 6.x.y release
#BASE_ASAHI_TAG="asahi-${MY_BASE}-3"
BASE_ASAHI_TAG="${ASAHI_TAG}"

DESCRIPTION="Linux kernel built with Asahi and Gentoo patches"
HOMEPAGE="
	https://asahilinux.org
	https://wiki.gentoo.org/wiki/Project:Distribution_Kernel
	https://www.kernel.org/
"

SRC_URI+="
	https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/${BASE_P}.tar.xz
	https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/patch-${PATCH_PV}.xz
	https://dev.gentoo.org/~mgorny/dist/linux/${PATCHSET}.tar.xz
	https://github.com/projg2/gentoo-kernel-config/archive/${GENTOO_CONFIG_VER}.tar.gz
		-> gentoo-kernel-config-${GENTOO_CONFIG_VER}.tar.gz
	https://github.com/AsahiLinux/linux/compare/v${PATCH_PV}...${BASE_ASAHI_TAG}.diff
		-> linux-${BASE_ASAHI_TAG}.diff
	verify-sig? (
		https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/sha256sums.asc
			-> linux-$(ver_cut 1).x-sha256sums-${SHA256SUM_DATE}.asc
	)
	amd64? (
		https://raw.githubusercontent.com/projg2/fedora-kernel-config-for-gentoo/${CONFIG_VER}/kernel-x86_64-fedora.config
			-> kernel-x86_64-fedora.config.${CONFIG_VER}
	)
	arm64? (
		https://raw.githubusercontent.com/projg2/fedora-kernel-config-for-gentoo/${CONFIG_VER}/kernel-aarch64-fedora.config
			-> kernel-aarch64-fedora.config.${CONFIG_VER}
	)
	ppc64? (
		https://raw.githubusercontent.com/projg2/fedora-kernel-config-for-gentoo/${CONFIG_VER}/kernel-ppc64le-fedora.config
			-> kernel-ppc64le-fedora.config.${CONFIG_VER}
	)
	riscv? (
		https://raw.githubusercontent.com/projg2/fedora-kernel-config-for-gentoo/${CONFIG_VER}/kernel-riscv64-fedora.config
			-> kernel-riscv64-fedora.config.${CONFIG_VER}
	)
	x86? (
		https://raw.githubusercontent.com/projg2/fedora-kernel-config-for-gentoo/${CONFIG_VER}/kernel-i686-fedora.config
			-> kernel-i686-fedora.config.${CONFIG_VER}
	)
"
S=${WORKDIR}/${BASE_P}

LICENSE="GPL-2"
SLOT="asahi-${PV}"
KEYWORDS="arm64"
IUSE="debug experimental hardened"
# mask untested USE flags
REQUIRED_USE="
	arm64? ( !experimental !secureboot )
	arm? ( savedconfig )
	hppa? ( savedconfig )
	sparc? ( savedconfig )
"

# Rust is non-negotiable for the dist kernel
DEPEND="
	${DEPEND}
	sys-boot/m1n1
	sys-boot/u-boot
"
BDEPEND="
	dev-util/bindgen
	debug? ( dev-util/pahole )
	verify-sig? ( >=sec-keys/openpgp-keys-kernel-20250702 )
"
PDEPEND="
	>=virtual/dist-kernel-${PATCH_PV}
"

QA_FLAGS_IGNORED="
	usr/src/linux-.*/scripts/gcc-plugins/.*.so
	usr/src/linux-.*/vmlinux
	usr/src/linux-.*/arch/powerpc/kernel/vdso.*/vdso.*.so.dbg
"

VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/kernel.org.asc

src_unpack() {
	if use verify-sig; then
		cd "${DISTDIR}" || die
		verify-sig_verify_signed_checksums \
			"linux-$(ver_cut 1).x-sha256sums-${SHA256SUM_DATE}.asc" \
			sha256 "${BASE_P}.tar.xz patch-${PATCH_PV}.xz"
		cd "${WORKDIR}" || die
	fi

	default
}

src_prepare() {
	local patch
	eapply "${WORKDIR}/patch-${PATCH_PV}"
	for patch in "${WORKDIR}/${PATCHSET}"/*.patch; do
		eapply "${patch}"
		# non-experimental patches always finish with Gentoo Kconfig
		# when ! use experimental, stop applying after it
		if [[ ${patch} == *Add-Gentoo-Linux-support-config-settings* ]] &&
			! use experimental
		then
			break
		fi
	done

	eapply "${DISTDIR}/linux-${BASE_ASAHI_TAG}.diff"
	eapply "${FILESDIR}/${PN}-6.8-config-gentoo-Drop-RANDSTRUCT-from-GENTOO_KERNEL_SEL.patch"

	default

	# add Gentoo patchset version
	local extraversion=${PV#${PATCH_PV}}
	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${extraversion/_/-}:" Makefile || die

	local biendian=false

	# prepare the default config
	case ${ARCH} in
		arm | hppa | loong | sparc)
			> .config || die
		;;
		amd64)
			cp "${DISTDIR}/kernel-x86_64-fedora.config.${CONFIG_VER}" .config || die
			;;
		arm64)
			cp "${DISTDIR}/kernel-aarch64-fedora.config.${CONFIG_VER}" .config || die
			biendian=true
			;;
		ppc)
			# assume powermac/powerbook defconfig
			# we still package.use.force savedconfig
			cp "${WORKDIR}/${BASE_P}/arch/powerpc/configs/pmac32_defconfig" .config || die
			;;
		ppc64)
			cp "${DISTDIR}/kernel-ppc64le-fedora.config.${CONFIG_VER}" .config || die
			biendian=true
			;;
		riscv)
			cp "${DISTDIR}/kernel-riscv64-fedora.config.${CONFIG_VER}" .config || die
			;;
		x86)
			cp "${DISTDIR}/kernel-i686-fedora.config.${CONFIG_VER}" .config || die
			;;
		*)
			die "Unsupported arch ${ARCH}"
			;;
	esac

	# use CONFIG_LOCALVERSION to provide "asahi" and "dist" annotations.
	local myversion="-asahi-dist"
	use hardened && myversion+="-hardened"
	echo "CONFIG_LOCALVERSION=\"${myversion}\"" > "${T}"/version.config || die
	local dist_conf_path="${WORKDIR}/gentoo-kernel-config-${GENTOO_CONFIG_VER}"

	local merge_configs=(
		"${T}"/version.config
		"${dist_conf_path}"/base.config
		"${dist_conf_path}"/6.12+.config
	)
	use debug || merge_configs+=(
		"${dist_conf_path}"/no-debug.config
		"${FILESDIR}"/linux-6.10_disable_debug_info_btf.config
	)
	if use hardened; then
		merge_configs+=( "${dist_conf_path}"/hardened-base.config )

		tc-is-gcc && merge_configs+=( "${dist_conf_path}"/hardened-gcc-plugins.config )

		if [[ -f "${dist_conf_path}/hardened-${ARCH}.config" ]]; then
			merge_configs+=( "${dist_conf_path}/hardened-${ARCH}.config" )
		fi
	fi

	# this covers ppc64 and aarch64_be only for now
	if [[ ${biendian} == true && $(tc-endian) == big ]]; then
		merge_configs+=( "${dist_conf_path}/big-endian.config" )
	fi

	use secureboot && merge_configs+=(
		"${dist_conf_path}/secureboot.config"
		"${dist_conf_path}/zboot.config"
	)

	# deselect all non APPLE arm64 ARCHs
	merge_configs+=(
		"${FILESDIR}"/linux-6.17_arm64_deselect_non_apple_arch.config
	)
	# adjust base config for Apple silicon systems
	merge_configs+=(
		"${FILESDIR}"/linux-6.8_arch_apple_overrides.config
	)

	# amdgpu no longer builds with clang (issue #113)
	merge_configs+=(
		"${FILESDIR}"/linux-6.10_drop_amdgpu.config
	)

	# apple silicon specific configs
	merge_configs+=(
		arch/arm64/configs/asahi.config
	)

	kernel-build_merge_configs "${merge_configs[@]}"
}

src_install() {
	# call kernel-build's scr_install
	kernel-build_src_install

	# symlink installed *.dtbs back into kernel "source" directory
	for dtb in "${ED}/lib/modules/${KV_FULL}/dtb/apple/"*.dtb; do
		local basedtb=$(basename ${dtb})
		dosym -r "${dtb##${ED}}" "/usr/src/linux-${KV_FULL}/arch/arm64/boot/dts/apple/${basedtb}"
	done
}

pkg_postinst() {
	einfo "For more information about Asahi Linux please visit ${HOMEPAGE},"
	einfo "or consult the Wiki at https://github.com/AsahiLinux/docs/wiki."
	kernel-build_pkg_postinst
}
