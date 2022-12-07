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

if [[ ${PV} != ${PV/_rc} ]] ; then
    # $PV is expected to be of following form: 6.0_rc5_p1
    MY_P="asahi-$(ver_rs 2 - $(ver_cut 1-4))-$(ver_cut 6)"
else
    # $PV is expected to be of following form: 5.19.0_p1
    MY_P="asahi-$(ver_cut 1-2)-$(ver_cut 5)"
fi

DESCRIPTION="Asahi Linux kernel sources"
HOMEPAGE="https://asahilinux.org"
KERNEL_URI="https://github.com/AsahiLinux/linux/archive/refs/tags/${MY_P}.tar.gz -> ${PN}-${PV}.tar.gz"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI}"
IUSE="experimental rust"
BDEPEND="${BDEPEND}
	rust? ( >=virtual/rust-1.62.0 )
"

KEYWORDS="~arm64"

src_unpack() {
    unpack ${PN}-${PV}.tar.gz || die "Could not unpack the archive"
    mv linux-${MY_P} linux-${KV_FULL} || die "Could not move source tree"
}

src_prepare() {
    default
    cd "${WORKDIR}/linux-${KV-FULL}"
    # No genpatches available for 6.1 just yet
    #handle_genpatches --set-unipatch-list
    #[[ -n ${UNIPATCH_LIST} || -n ${UNIPATCH_LIST_GENPATCHES} || -n ${UNIPATCH_LIST_DEFAULT} ]] && \
    #    unipatch "${UNIPATCH_LIST_DEFAULT} ${UNIPATCH_LIST_GENPATCHES} ${UNIPATCH_LIST}"
    #unpack_fix_install_path
    #env_setup_xmakeopts
    cd "${S}" || die
}

pkg_postinst() {
    #kernel-2_pkg_postinst
    einfo "For more information about Asahi Linux please visit ${HOMEPAGE},"
    einfo "or consult the Wiki at https://github.com/AsahiLinux/docs/wiki."
    use rust && ewarn "Building kernel rust drivers requires the bindgen-cli crate and"
    use rust && ewarn "Rust to be built with the rust-src USE flag enabled!"
    kernel-2_pkg_postinst
}
