# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
K_SECURITY_UNSUPPORTED="1"
ETYPE="sources"
inherit kernel-2
detect_version

DESCRIPTION="Asahi Linux kernel sources"
HOMEPAGE="https://asahilinux.org"
SRC_URI="https://github.com/AsahiLinux/linux/archive/refs/tags/asahi-5.19-5.tar.gz -> ${PN}-${PV}.tar.gz"
MY_P="asahi-5.19-5"
S="${WORKDIR}/linux-${KV_FULL}"

KEYWORDS="arm64"


src_unpack() {
    unpack ${PN}-${PV}.tar.gz || die "Could not unpack the archive"
    mv linux-${MY_P} linux-${KV_FULL} || die "Could not move source tree"
}


src_prepare() {
    default
    unpack_fix_install_path
}
