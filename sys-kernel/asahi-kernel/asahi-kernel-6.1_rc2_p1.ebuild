# Copyright 2020-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit kernel-build toolchain-funcs

K_SECURITY_UNSUPPORTED=1
CONFIG_VER=config-${PV}

DESCRIPTION="Asahi Linux dist kernel"
HOMEPAGE="https://asahilinux.org"
KEYWORDS="~arm64"
LICENSE="GPL-2"

#PDEPEND="
#    >=virtual/dist-kernel-6.0
#"


if [[ ${PV} != ${PV/_rc} ]] ; then
    # $PV is expected to be of following form: 6.0_rc5_p1
    MY_P="asahi-$(ver_rs 2 - $(ver_cut 1-4))-$(ver_cut 6)"
else
    # $PV is expected to be of following form: 5.19.0_p1
    MY_P="asahi-$(ver_cut 1-2)-$(ver_cut 5)"
fi

SRC_URI+="
    https://github.com/AsahiLinux/linux/archive/refs/tags/${MY_P}.tar.gz -> ${PN}-${PV}.tar.gz
"
S="${WORKDIR}/linux-${MY_P}"

src_unpack() {
    unpack ${PN}-${PV}.tar.gz || die "Could not unpack kernel sources"
}

src_prepare() {
    default
    case ${ARCH} in
        arm64)
            cp "${FILESDIR}/${CONFIG_VER}" .config || die
            ;;
        *)
            die "Asahi kernels are not supported on ${ARCH}"
            ;;
    esac
}
