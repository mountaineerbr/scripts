#!/usr/bin/env bash
# aur.sh - list aur packges
# v0.1.13  june/2025  by mountaineerbr  GPLv3+

#chrome on windows 10
UAG='user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36'  #;UAG='user-agent: Mozilla/5.0 Gecko'
#cache directory
#defaults=/tmp/aur.sh.cache
CACHEDIR="${TMPDIR:-/tmp}/${0##*/}".tmp

HELP="NAME
	${0##*/} -- list aur packages


SYNOPSIS
	${0##*/} PKG_NAME [SEARCH_BY] [SORT_BY]
	${0##*/} -p PKG_NAME
	${0##*/} -u
	${0##*/} [.|..|'']


	List, sort and print PKGBUILD of AUR packages.

	Package info scraping can be set. Operator \`.' prints a list with
	all AUR packages, \`..' prints package metadata (json) and empty
	string scrapes too (slow).

	Keys for SEARCH_BY and SORT_BY are as follows:

		nd 	 name/description
		n 	 name
		b 	 pkg base
		N 	 exact name
		B 	 exact pkg base
		k 	 keywords
		m 	 maintainer
		c 	 co-maintainer
		M 	 maintainer/co-maintainer
		s 	 submitter
		v	 votes          #sort only
		p 	 popularity     #sort only
		l 	 last modified  #sort only


OPTIONS
	-h 	This help page.
	-l 	Update disc cache file immediately.
	-p 	Print package PKGBUILD (GitLab or AUR).
	-pp 	Same as -p, force PKGBUILD from AUR.
	-u 	Check for system package updates."


#cache files
#wrapper around curl/wget commands
cachef()
{
	local url fname fpath ret
	url="${@: -1}" fname="${url/\/\/aur.archlinux.org\//aur}.cache"
	fname="${fname/https:}" fname="${fname/http:}" fname="${fname//[\/:]/.}"
	fname="${fname//../.}" fname="${fname//../.}" fname="${fname//../.}" fname="${fname#.}"
	fpath="$CACHEDIR/$fname" SKIP=

	if [[ ! -s "$fpath" || "$OPTL" -gt 0 ]] || [[ -n $(find "$fpath" -mtime +2) ]]
	then
		trap "rm -- \"$fpath\" ;exit" INT TERM
		"${YOURAPP[@]}" "$url" | tee -- "$fpath" ;ret="${PIPESTATUS[0]}"
		trap \  INT TERM
		grep --color=always -qi -e '404 Not Found' -e '404 - Page Not Found' -e 'Invalid branch:' -e 'No packages matched your search criteria' -e 'class="error">Path not found<' "$fpath" >&2 && {
			rm -- "$fpath" 2>/dev/null ;ret=1
		}
	else 	cat -- "$fpath" ;ret=$? SKIP=1
		echo "CACHE: <$fpath>" >&2
	fi

	return ${ret:-0}
}

#select option from pos args
optnf()
{
	case "${1}" in
		nd) 	echo ${2} name/description;;
		n) 	echo ${2} name;;
		b) 	echo ${2} pkg base;;
		N) 	echo ${2} exact name;;
		B) 	echo ${2} exact pkg base;;
		k) 	echo ${2} keywords;;
		m) 	echo ${2} maintainer;;
		c) 	echo ${2} co-maintainer;;
		M) 	echo ${2} maintainer/co-maintainer;;
		s) 	echo ${2} submitter;;
		v)	echo ${2} votes;;          #sort only
		p) 	echo ${2} popularity;;     #sort only
		l) 	echo ${2} last modified;;  #sort only
		'') 	;;
		*) 	return 1;;
	esac
}

#aurf helpers
#process aur page
aur_procf()
{
	local buf REPLY
	exec 0< <(sed -n  -e 's/&gt;/>/g ;s/&lt;/</g ;s/&amp;/\&/g ;s/&nbsp;/ /g ;s/&quot;/"/g' \
		-e "s/&#39;/'/g" -e 's/.*<tr\>.*/<p>--------<\/p>\n&/' \
		-e 's/^\s*//' -e '/<tbody>/,/<\/tbody>/ p' \
		| sed -e 's/<[^>]*>//g' -e '/^\s*$/d')
	while read
	do 	if [[ $REPLY = --* ]]
		then 	echo "$buf" ;buf=
		else 	buf="${buf:+$buf$'\t'}""${REPLY}"
		fi
	done
	[[ -n $buf ]] && echo "$buf"
}
#aur_getf [query] [search_by] [sort_by] [output_start]
aur_getf()
{
	cachef "https://aur.archlinux.org/packages?O=${4:-0}&SeB=${2:-n}&K=${1}&outdated=&SB=${3:-n}&SO=d&PP=${pagepkg:-250}&submit=Go"
}
#O   = start of output
#SB  = Sort By:   n - name, v - votes, p - popularity, m - maintainer, l = last modified
#SeB = Search By: n - name, nd - name/description, N - exact name, k - keywords, m - maintainer, s - submitter

#simple aur search
aurf()
{
	local page info pagepkg sfactor wait n SKIP
	pagepkg=250  #pkgs per page
	n=1
	trap exit INT HUP

	page=$(aur_getf "${@:1:3}") || return
	[[ -n $PKGOPT ]] && { 	echo "$page" ;return ;}
	info=($(sed -n -E -e 's/.*\<([0-9]+) [Pp]ackages [Ff]ound.*/\1/ p' -e 's/.*[Pp]age ([0-9]+) of ([0-9]+).*/\1 \2/ p' <<<"$page"))
	((sfactor=info[0]/3030)) ;((sfactor<5)) || sfactor=5
	fun()
	{
		echo "$page"
		for ((p=pagepkg;p<info[0];p+=pagepkg))
		do 	aur_getf "$1" "$2" "$3" $((++n))
			echo "page: $((n+1))/${info[2]}    pkgs: $p/${info[0]}    query: ${QUERY}" >&2
			if ((p!=pagepkg)) && ((OPTSCRAPE-SKIP))
			then 	((!sfactor)) && sleep 0.6 || sleep $sfactor
			fi
		done
	}
	if [[ -t 1 ]] && ((!OPTSCRAPE))
	then 	fun | aur_procf | column -s$'\t' -et -NNAME,VERSION,VOTES,POP,DESC,MAINTAINER -RVOTES,POP | less -S
	else 	fun | aur_procf 
	fi
	echo "packages_: ${info[0]:-0}    query: ${QUERY}" >&2
}
#<p>
#    922 packages found.
#        Page 1 of 4.
#   </p>

#get package build
pkgbf()
{
	local url urlb urlc page
	url=https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD
	urlb=https://aur.archlinux.org/packages
	urlc=https://gitlab.archlinux.org/archlinux/packaging/packages/${1}/-/raw/main/PKGBUILD

	if ((OPTP<2)) && page=$(curl -f\# "$urlc")  #gitlab
		[[ $page =~ \<html[^\>]*\> ]]
	then 	if [[ $(PKGOPT=1 aurf "${1}" n p) =~ \<\a\ href=\"/packages/([^\"/]*)\"\> ]] &&
			[[ $(cachef "$urlb/${BASH_REMATCH[1]}") =~ \<\a\ href=\"/pkgbase/([^\"/]*)\"\> ]]
		then 	echo "match: ${BASH_REMATCH[1]}"
			page=$(cachef "$url?h=${BASH_REMATCH[1]}")
		fi
	fi

	if [[ ! ${page} =~ pkg[bn]a[sm]e= ]] && page=$(cachef "$url?h=${1}")  #aur
		[[ $page =~ \<div\ class=[\'\"]error[\'\"]\>[Ii]nvalid\ [Bb]ranch: ]]
	then 	return 2
	fi

	echo "$page"
}

aur_pkgf()
{
	local pkgs url
	if [[ $1 = .. ]]
	then 	url=https://aur.archlinux.org/packages-meta-ext-v1.json.gz
		if command -v jq &>/dev/null
		then 	cachef "$url" | jq .
		else 	cachef "$url"
		fi
	else 	pkgs=$(cachef https://aur.archlinux.org/packages.gz)
		echo "$pkgs"$'\n'"packages_: $(wc -l <<<"$pkgs")"
	fi
}

aur_updatesf()
{
	local url tmp pkg a b
	url='https://aur.archlinux.org/rpc?v=5&'
	tmp=/tmp/local.pkgs

	pacman -Qm | sort >| "${tmp}"
	
	curl -\# "${url}type=info$(printf '&arg[]=%s' $(cut -f 1 "${tmp}"))" \
	| jq -r '.results[]|.Name+" "+.Version' \
	| sort | join "${tmp}" - \
	| while read pkg a b; do
		[ "$(vercmp $a $b)" -lt 0 ] && echo $pkg;
	done
	rm -- "$tmp"
}
#https://bbs.archlinux.org/viewtopic.php?id=283956


#parse opts
while getopts ahlpu c
do 	case $c in
		a) 	: compatibility with ala.sh ;;
		h) 	echo "$HELP" ;exit ;;
		l) 	OPTL=1 ;;
		p) 	((++OPTP)) ;;
		u) 	OPTU=1;;
		?) 	exit ;;
	esac
done ; unset c
shift $((OPTIND -1))

#check for pkgs
if command -v curl &>/dev/null; then
	YOURAPP=(curl --compressed --insecure -Lb nil)
elif command -v wget &>/dev/null; then
	YOURAPP=(wget -O- -q --show-progress)
else 	printf '%s: warning -- curl or wget is required\n' "${0##*/}" >&2
	exit 1
fi
YOURAPP=("${YOURAPP[@]}" --header "$UAG" --header 'Referer: https://aur.archlinux.org/packages/')

#make cache directory
[[ -d "$CACHEDIR" ]] || mkdir -p -- "$CACHEDIR" || exit

#set pos args
if [[ -z $1 && -n ${1+x} ]]
then 	OPTSCRAPE=1
elif [[ $1 = . || $1 = .. ]]
then 	OPTSCRAPE=2
elif [[ -z $1 ]] && ((!OPTU))
then 	echo package name required >&2
	exit 2
fi

if var=$(optnf "${@:$#-1:1}" search_by: && optnf "${@:$#}" sort_by__:)
then 	echo "$var" ;var=("${@:1:$#-2}")
	set -- "${var[*]}" "${@:$#-1:1}" "${@:$#}"
elif optnf "${@:$#}" search_by:
then 	var=("${@:1:$#-1}")
	set -- "${var[*]}" "${@:$#}"
else 	set -- "$*"
fi ;unset var

QUERY="${1:-scrape}"

set -- "${1// /%20}" "${@:2}"

#fun
if ((OPTU))
then 	aur_updatesf
elif ((OPTSCRAPE>1))
then 	aur_pkgf "$@"
elif ((OPTP))
then 	pkgbf "$@"
else 	aurf "$@"
fi

#aur database
#https://aur.archlinux.org/packages-meta-v1.json.gz
#https://lists.archlinux.org/archives/list/aur-general@lists.archlinux.org/message/D4YC6Y7L4T5VSEONUCLHOX2R4NJKNIDP/
