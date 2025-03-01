# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="speakersafetyd program user"
ACCT_USER_ID=547
ACCT_USER_GROUPS=( audio speakersafetyd )
acct-user_add_deps
SLOT="0"
