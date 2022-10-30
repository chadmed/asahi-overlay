# Copyright 2020-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

inherit kernel-build toolchain-funcs

EAPI=8
K_SECURITY_UNSUPPORTED=1
CONFIG_VER=asahi-config-${PV}

DESCRIPTION="Asahi Linux dist kernel"
HOMEPAGE="https://asahilinux.org"
KEYWORDS="~arm64"
LICENSE="GPL-2"

PDEPEND="
    >=virtual/dist-kernel-6.0
"


if [[ ${PV} != ${PV/_rc} ]] ; then
    # $PV is expected to be of following form: 6.0_rc5_p1
    MY_P="asahi-$(ver_rs 2 - $(ver_cut 1-4))-$(ver_cut 6)"
else
    # $PV is expected to be of following form: 5.19.0_p1
    MY_P="asahi-$(ver_cut 1-2)-$(ver_cut 5)"
fi

SRC_URI+="
    https://github.com/AsahiLinux/linux/archive/refs/tags/${MY_P}.tar.gz -> ${PN}-${PV}.tar.gz
    https://chadmed.github.io/res/${CONFIG_VER}.config
"

src_unpack() {
    unpack ${PN}-${PV}.tar.gz || die "Could not unpack kernel sources"
    mv linux-${MY_P} linux-${KV_FULL} || die "Could not move source tree"
}

src_prepare() {
    default
    cd "${WORKDIR}/linux-${KV-FULL}" || die
    case ${ARCH} in
        arm64)
            cp "${DISTDIR}/${CONFIG_VER}.config" .config || die
            ;;
        *)
            die "Asahi kernels are not supported on ${ARCH}"
            ;;
    esac
}
