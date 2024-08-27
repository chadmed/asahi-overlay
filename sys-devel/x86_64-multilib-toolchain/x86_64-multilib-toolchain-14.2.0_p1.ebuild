# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit edo flag-o-matic toolchain-funcs

GCC_PV=14.2.0
BINUTILS_PV=2.43.1
KERNEL_PV=6.10
GLIBC_PV=2.40

DESCRIPTION="All-in-one x86 toolchain for packages that need this specific crosscompiler"
HOMEPAGE="
	https://gcc.gnu.org/
	https://sourceware.org/binutils/
	https://www.kernel.org/
"
SRC_URI="
	mirror://gnu/binutils/binutils-${BINUTILS_PV}.tar.xz
	https://www.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_PV}.tar.xz
	mirror://gnu/glibc/glibc-${GLIBC_PV}.tar.xz
"
if [[ ${GCC_PV} == *-* ]]; then
	SRC_URI+=" mirror://gcc/snapshots/${GCC_PV}/gcc-${GCC_PV}.tar.xz"
else
	SRC_URI+="
		mirror://gcc/gcc-${GCC_PV}/gcc-${GCC_PV}.tar.xz
		mirror://gnu/gcc/gcc-${GCC_PV}/gcc-${GCC_PV}.tar.xz
	"
fi
S="${WORKDIR}"

# l1:binutils+gcc, l2:gcc(libraries)
LICENSE="
	GPL-3+
	LGPL-3+ || ( GPL-3+ libgcc libstdc++ gcc-runtime-library-exception-3.1 )
	GPL-2
	LGPL-2.1+ BSD HPND ISC inner-net rc PCRE
"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"
IUSE="+bin-symlinks custom-cflags +strip"

RDEPEND="
	dev-libs/gmp:=
	dev-libs/mpc:=
	dev-libs/mpfr:=
	sys-libs/zlib:=
	virtual/libiconv
	bin-symlinks? (
		!cross-x86_64-multilib-linux-gnu/binutils
		!cross-x86_64-multilib-linux-gnu/gcc
		!cross-x86_64-multilib-linux-gnu/glibc
	)
"
DEPEND="${RDEPEND}"

PATCHES=()

pkg_pretend() {
	[[ ${MERGE_TYPE} == binary ]] && return

	tc-is-cross-compiler &&
		die "cross-compilation of the toolchain itself is unsupported"
}

src_prepare() {
	# rename directories to simplify both patching and the ebuild
	mv binutils{-${BINUTILS_PV},} || die
	mv gcc{-${GCC_PV},} || die
	mv linux-{${KERNEL_PV},headers} || die
	mv glibc{-${GLIBC_PV},} || die

	default
}

src_compile() {
	# src_compile is kept similar to dev-util/mingw64-toolchain
	# at least for now for ease of comparison etc.
	#
	# not great but do everything in src_compile given bootstrapping
	# process needs to be done in steps of configure+compile+install
	# (done modular to have most package-specific things in one place)

	CTARGET=x86_64-multilib-linux-gnu

	X86MT_D=${T}/root # moved to ${D} in src_install
	local x86mtdir=/usr/lib/${PN}
	local prefix=${EPREFIX}${x86mtdir}
	local sysroot=${X86MT_D}${prefix}
	local -x PATH=${sysroot}/bin:${PATH}

	filter-lto
	use custom-cflags || strip-flags # fancy flags are not realistic here

	local hdr_dir="${sysroot}/include"

	# global configure flags
	local conf=(
		--build=${CBUILD:-${CHOST}}
		--target=${CTARGET}
		--{doc,info,man}dir=/.skip # let the real binutils+gcc handle docs
		MAKEINFO=: #922230
	)

	# binutils
	local conf_binutils=(
		--prefix="${prefix}"
		--host=${CHOST}
		--disable-cet
		--disable-default-execstack
		--disable-nls
		--disable-shared
		--with-system-zlib
		--without-debuginfod
		--without-msgpack
		--without-zstd
	)

	local conf_glibc=(
		--enable-stack-protector=strong
		--disable-cet
		--enable-kernel=3.2.0
		--without-selinux
		--disable-werror
		--enable-bind-now
		--enable-fortify-source
		--disable-profile
		--without-gd
		--with-headers="${hdr_dir}"
		--prefix="${prefix}"
		--sysconfdir='$(prefix)/etc'
		--localstatedir='$(prefix)/var'
		--mandir='$(prefix)/share/man'
		--infodir='$(prefix)/share/info'
		--libexecdir='$(libdir)/misc/glibc'
		--disable-systemtap
		--disable-nscd
		--disable-timezone-tools
	)

	local conf_glibc_amd64=(
		--libdir='$(prefix)/lib64'
		--host=${CTARGET}
	)

	local conf_glibc_x86=(
		--libdir='$(prefix)/lib'
		--host=i686-multilib-linux-gnu
	)

	x86mt-binutils() {
		# symlink gcc's lto plugin for AR (bug #854516)
		ln -s ../../libexec/gcc/${CTARGET}/${GCC_PV%%[.-]*}/liblto_plugin.so \
			"${sysroot}"/lib/bfd-plugins || die
	}

	# gcc (minimal -- if need more, disable only in stage1 / enable in stage3)
	local conf_gcc=(
		--prefix="${prefix}"
		--host=${CHOST}
		--disable-bootstrap
		--disable-cet
		--disable-gcov #843989
		--disable-gomp
		--disable-libquadmath
		--disable-libsanitizer
		--disable-libssp
		--disable-libvtv
		--disable-werror
		--with-gcc-major-version-only
		--with-system-zlib
		--without-isl
		--without-zstd
		--disable-libgomp
		--enable-poison-system-directories
	)

	local conf_gcc_stage1=(
		--disable-cc1
		--enable-languages=c
		--disable-libatomic
		--disable-threads
		--without-headers
		--disable-shared
	)

	local conf_gcc_stage2=(
		--enable-languages=c,c++
		--enable-threads
		--enable-multilib
		--with-multilib-list=m64,m32
		--with-build-sysroot="${sysroot}"
		--with-sysroot="${prefix}"
		--with-native-system-header-dir="/include"
	)

	# libstdc++ may misdetect sys/sdt.h on systemtap-enabled system and fail
	# (not passed in conf_gcc above given it is lost in sub-configure calls)
	local -x glibcxx_cv_sys_sdt_h=no

	# x86mt-build <path/package-name>
	# -> ./configure && make && make install && x86mt-package()
	# passes conf and conf_package to configure, and users can add options
	# through environment with e.g.
	#   X86MT_BINUTILS_CONF="--some-option"
	#   EXTRA_ECONF="--global-option" (generic naming for if not reading this)
	x86mt-build() {
		local id=${1##*/}
		local build_dir=${WORKDIR}/${1}${2+_${2}}-build

		# econf is not allowed in src_compile and its defaults are
		# mostly unused here, so use configure directly
		local conf=( "${WORKDIR}/${1}"/configure "${conf[@]}" )

		local -n conf_id=conf_${id} conf_id2=conf_${id}_${2}
		[[ ${conf_id@a} == *a* ]] && conf+=( "${conf_id[@]}" )
		[[ ${2} && ${conf_id2@a} == *a* ]] && conf+=( "${conf_id2[@]}" )

		local -n extra_id=X86MT_${id^^}_CONF extra_id2=X86MT_${id^^}_${2^^}_CONF
		conf+=( ${EXTRA_ECONF} ${extra_id} ${2+${extra_id2}} )

		einfo "Building ${id}${2+ ${2}} in ${build_dir} ..."

		mkdir -p "${build_dir}" || die
		pushd "${build_dir}" >/dev/null || die

		edo "${conf[@]}"
		emake MAKEINFO=: V=1
		# -j1 to match bug #906155, other packages may be fragile too
		emake -j1 MAKEINFO=: V=1 DESTDIR="${X86MT_D}" install

		declare -f x86mt-${id} >/dev/null && edo x86mt-${id}
		declare -f x86mt-${id}_${2} >/dev/null && edo x86mt-${id}_${2}

		popd >/dev/null || die
	}

	# build with same ordering that crossdev would do
	x86mt-build binutils
	x86mt-build gcc stage1

	einfo "Building linux-headers in ${WORKDIR}/linux-headers ..."
	pushd linux-headers >/dev/null || die
	chmod -R a+r-w+X,u+w * || die
	emake headers_install INSTALL_HDR_PATH="${hdr_dir}/.." ARCH=x86 CROSS_COMPILE="${CTARGET}-" HOSTCC="$(tc-getBUILD_CC)"
	rm -rf "${hdr_dir}/scsi" || die
	popd >/dev/null || die
	(

		export libc_cv_cxx_link_ok=no
		export CXX=
		CHOST=${CTARGET} strip-unsupported-flags
		local oldcc="${CC}"
		# Fix compilation on systems which use a Clang/LLVM toolchain
		export CC="${CTARGET}-multilib-linux-gnu-gcc -m32"
		export AS="${CTARGET}-multilib-linux-gnu-as"
		export AR="${CTARGET}-multilib-linux-gnu-ar"
		export RANLIB="${CTARGET}-multilib-linux-gnu-ranlib"
		export OBJCOPY="${CTARGET}-multilib-linux-gnu-objcopy"
		export NM="${CTARGET}-multilib-linux-gnu-nm"
		export libc_cv_slibdir="${prefix}/lib"
		x86mt-build glibc x86
		export libc_cv_slibdir="${prefix}/lib64"
		export CC="${CTARGET}-multilib-linux-gnu-gcc"
		x86mt-build glibc amd64
	)
	local file
	while read -rd '' file ; do
		sed -i "s|${prefix}/|/|g" "${file}" || die
	done < <(grep -lZIF "ld script" "${sysroot}"/lib{,64}/lib*.{a,so} 2>/dev/null)

	x86mt-build gcc stage2

	if use bin-symlinks; then
		mkdir -p -- "${X86MT_D}${EPREFIX}"/usr/bin/ || die
		local bin
		for bin in "${sysroot}"/bin/*; do
			if [[ "$bin" == *"${CTARGET}"* ]]; then
				ln -rs -- "${bin}" "${X86MT_D}${EPREFIX}"/usr/bin/ || die
			fi
		done
	fi

	# portage doesn't know the right strip executable to use for CTARGET
	# and it can lead to .a mangling, notably with 32bit (breaks toolchain)
	dostrip -x ${x86mtdir}/{{${CTARGET}/,}lib{,64},{,s}bin,lib/gcc/${CTARGET}}

	if use strip; then
		einfo "Stripping ${CTARGET} static libraries ..."
#       find "${sysroot}"/{,lib/gcc/}${CTARGET} -type f -name '*.a' \
#            -exec ${CTARGET}-strip --strip-unneeded {} + || die
	fi
}

src_install() {
	mv "${X86MT_D}${EPREFIX}"/* "${ED}" || die

	find "${ED}" -type f -name '*.la' -delete || die
}

pkg_postinst() {
	use bin-symlinks && has_version dev-util/shadowman && [[ ! ${ROOT} ]] &&
		eselect compiler-shadow update all

	if [[ ! ${REPLACING_VERSIONS} ]]; then
		elog "Note that this package is primarily intended for FEX, and related"
		elog "packages to depend on without needing a manual crossdev setup."
		elog
		elog "Settings are oriented only for what these need and simplicity."
		elog "Use sys-devel/crossdev if need full toolchain/customization:"
		elog "    https://wiki.gentoo.org/wiki/Crossdev"
	fi
}

pkg_postrm() {
	use bin-symlinks && has_version dev-util/shadowman && [[ ! ${ROOT} ]] &&
		eselect compiler-shadow clean all
}
