# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
K_SECURITY_UNSUPPORTED="1"
ETYPE="sources"
#K_WANT_GENPATCHES="base extras experimental"
#K_GENPATCHES_VER="5"
K_NODRYRUN="1"

inherit kernel-2
detect_version
detect_arch

DESCRIPTION="Asahi Linux kernel sources"
HOMEPAGE="https://asahilinux.org"
KERNEL_URI="https://github.com/AsahiLinux/linux/archive/refs/tags/asahi-6.0-rc5-4.tar.gz -> ${PN}-${PV}.tar.gz"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI}"
MY_P="asahi-6.0-rc5-1"
IUSE="experimental"

KEYWORDS="~arm64"


src_unpack() {
    unpack ${PN}-${PV}.tar.gz || die "Could not unpack the archive"
    mv linux-${MY_P} linux-${KV_FULL} || die "Could not move source tree"
}

src_prepare() {
    default
    cd "${WORKDIR}/linux-${KV-FULL}"
    # No genpatches available for 6.0 just yet
    #handle_genpatches --set-unipatch-list
    #[[ -n ${UNIPATCH_LIST} || -n ${UNIPATCH_LIST_GENPATCHES} || -n ${UNIPATCH_LIST_DEFAULT} ]] && \
    #    unipatch "${UNIPATCH_LIST_DEFAULT} ${UNIPATCH_LIST_GENPATCHES} ${UNIPATCH_LIST}"
    #unpack_fix_install_path
    #env_setup_xmakeopts
    cd "${S}" || die
}

pkg_postinst() {
    kernel-2_pkg_postinst
    einfo "For more information about Asahi Linux please visit ${HOMEPAGE},"
    einfo "or consult the Wiki at https://github.com/AsahiLinux/docs/wiki."
}
