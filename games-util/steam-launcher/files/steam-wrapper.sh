#!/bin/bash

# Disallow overriding STEAM_RUNTIME. Setting it to 0 is unsupported and largely
# ineffective. Setting it to 1 breaks things.
unset STEAM_RUNTIME

# Gentoo's lsb-release doesn't set this.
DISTRIB_RELEASE=$(. /etc/os-release; echo "${VERSION_ID}")
export DISTRIB_RELEASE

steam="${XDG_DATA_HOME:-${HOME}/.local/share}/Steam"
beta="${steam}/package/beta"

# The arm64 client currently requires opting into the beta.
[[ -s ${beta} ]] || install -D -m0600 /dev/stdin "${beta}" <<< publicbeta

STEAMCONFIG="${HOME}/.steam"
STEAMDATALINK="${STEAMCONFIG}/steam"
LAUNCHSTEAMPLATFORM="steamrtarm64"
LAUNCHSTEAMBOOTSTRAPFILE="${0%/*}"/../lib/steam/bootstraplinux_"${LAUNCHSTEAMPLATFORM}".tar.xz

# Steam Client uses "sdkarm64" path when launching games.
mkdir -p "${STEAMCONFIG}"
ln -sfn "${steam}/linuxarm64" "${STEAMCONFIG}/sdkarm64"

function install_bootstrap()
{
	STEAMDIR="$1"

	# Save the umask and set strong permissions
	omask="$(umask)"
	umask 0077

	echo "Setting up Steam content in $STEAMDIR" >&2 || :
	mkdir -p "$STEAMDIR"
	cd "$STEAMDIR"
	if ! tar xJf "$LAUNCHSTEAMBOOTSTRAPFILE" ; then
		echo "Failed to extract $LAUNCHSTEAMBOOTSTRAPFILE, aborting installation." >&2 || :
		exit 1
	fi
	ln -fns "$STEAMDIR" "$STEAMDATALINK"

	# Restore the umask
	umask "$omask"
}

if [[ ! -L "$STEAMDATALINK" ]] || [[ ! -x "${steam}/${LAUNCHSTEAMPLATFORM}/steam" ]]; then
	install_bootstrap "${steam}"
fi

PAGE_SIZE=$(getconf PAGESIZE)
if [[ ${PAGE_SIZE} != 4096 ]]; then
	if ! command -v muvm > /dev/null 2>&1; then
		msg="muvm is not installed. Steam requires muvm to run on AArch64 systems with page sizes other than 4096 bytes. Your system's page size is ${PAGE_SIZE} bytes"
		if command -v zenity > /dev/null 2>&1; then
			zenity --error --text "$msg"
		else
			echo "$msg" >&2 || :
		fi
		exit 2
	fi
	exec muvm -e=DISTRIB_RELEASE "${0%/*}"/../lib/steam/bin_steam.sh "${@}"
fi

. "${0%/*}"/../lib/steam/bin_steam.sh
