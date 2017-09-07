# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: eapi7-ver.eclass
# @MAINTAINER:
# PMS team <pms@gentoo.org>
# @AUTHOR:
# Ulrich Müller <ulm@gentoo.org>
# Michał Górny <mgorny@gentoo.org>
# @BLURB: Testing implementation of EAPI 7 version manipulators
# @DESCRIPTION:
# A stand-alone implementation of the version manipulation functions
# aimed for EAPI 7. Intended to be used for wider testing of
# the proposed functions and to allow ebuilds to switch to the new
# model early, with minimal change needed for actual EAPI 7.
#
# https://bugs.gentoo.org/482170
#
# Note: version comparison function is not included currently.

case ${EAPI:-0} in
	0|1|2|3|4|5)
		die "${ECLASS}: EAPI=${EAPI:-0} not supported";;
	6)
		;;
	*)
		die "${ECLASS}: EAPI=${EAPI} unknown";;
esac

# USAGE: <range> <max>
_version_parse_range() {
	local max_end=${2}
	[[ ${1} == [0-9]* ]] || die
	start=${1%-*}
	[[ ${1} == *-* ]] && end=${1#*-} || end=${start}
	[[ ${start} -ge 0 ]] || die
	if [[ ${end} ]]; then
		[[ ${start} -le ${end} ]] || die
		[[ ${end} -le ${max_end} ]] || die
	else
		end=${max_end}
	fi
}

# RETURNS:
# comp=( s0 c1 s1 c2 s2... )
# where s - separator, c - component
_version_split() {
	local v=$1 LC_ALL=C

	comp=()

	# get separators and components
	local s c
	while [[ ${v} ]]; do
		# cut the separator
		s="${v%%[a-zA-Z0-9]*}"
		v=${v:${#s}}
		# cut the next component; it can be either digits or letters
		[[ ${v} == [0-9]* ]] && c=${v%%[^0-9]*} || c=${v%%[^a-zA-Z]*}
		v=${v:${#c}}

		comp+=( "${s}" "${c}" )
	done
}

version_cut() {
	local start end
	local -a comp

	_version_split "${2-${PV}}"
	local max_end=$((${#comp[@]}/2))
	_version_parse_range "$1" "${max_end}"

	local IFS=
	if [[ ${start} -gt 0 ]]; then
		start=$(( start*2 - 1 ))
	fi
	echo "${comp[*]:start:end*2-start}"
}

version_rs() {
	local start end i
	local -a comp

	(( $# & 1 )) && _version_split "${@: -1}" || _version_split "${PV}"
	local max_end=$((${#comp[@]}/2 - 1))

	while [[ $# -ge 2 ]]; do
		_version_parse_range "$1" "${max_end}"
		for (( i = start*2; i <= end*2; i+=2 )); do
			comp[i]=$2
		done
		shift 2
	done

	local IFS=
	echo "${comp[*]}"
}
