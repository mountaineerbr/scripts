#!/usr/bin/env bash
# urlgrep.sh -- grep full-text urls
# v0.24  jan/2025  by mountaineerbr

JOBMAX=${JOBMAX:-4}

USER_AGENT="user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"

HELP="NAME
	${0##*/} -- Search Full-Text Web Content from a List of URLs


SYNOPSIS
	${0##*/} [GREP-OPTION...] PATTERN [URL_FILE]
	${0##*/} -h


	Grep full-text content of webpages from a list of URLs read via
	stdin, or as URL text file.


DESCRIPTION
	Read a URL list from stdin (one URL per line), filter HTML con-
	tent by a terminal web browser and run grep. By defaults, run
	\`$JOBMAX' jobs at a time.

	Pipe the URLs to the script, or set a URL file as the last
	command line positional argument.

	All command line options and arguments are passed to grep, except
	option -h and the URL text file path.

	URL targets will be downloaded locally to \`\$TMPDIR' to avoid
	unnecessarily re-accessing URLs in posterior searches.

	Set environmental variable \`\$JOBMAX' to change maximum simulta-
	neous jobs.

	Supports cURL, Wget and Wget2 for get programmes and W3M, ELinks,
	Links, Lynx or Sed (in that order) for markup filters.

	Carefully crafting the URL list is important as binary files may
	be downloaded! In such cases grep may throw erros, unless option
	-a is set.


PROOF OF CONCEPT
	The current shell script can be summarised in its simplest form:

	  while read
	  do  curl -s \"\$REPLY\" | grep \"\$@\" && echo \">>>\$REPLY\";
	  done;


URL LISTS
	Firefox

	All URLs:
	  echo 'select url from moz_places where 1;' |
	    sqlite3 ~/.mozilla/firefox/XXXXXXXX.default/places.sqlite

	Bookmarks:
	  echo 'select url from moz_bookmarks, moz_places where moz_places.id=moz_bookmarks.fk;' |
	    sqlite3 ~/.mozilla/firefox/XXXXXXXX.default/places.sqlite


	Google Chrome

	All URLs:
	  echo 'select url from urls where 1;' |
	    sqlite3 ~/.config/google-chrome/Default/History

	Bookmarks:
	  jq -r '..|.url? //empty' ~/.config/google-chrome/Default/Bookmarks


WARRANTY
	This programme is Free Software and is licensed under the
	GNU General Public License v3 or better and is distributed
	without support or bug corrections.


USAGE EXAMPLES
	Grep a single URL text:
	  echo www.example.com | ${0##*/} -e illustrative

	Pipe a URL list:
	  cat urlList.txt | ${0##*/} -i -e linux
	
	URL list is a file:
	  ${0##*/} -E -e 'REGEX' urlfile.txt


SCRIPT OPTIONS
	-h, --help
	    Print this help page."


#script help
case " ${*:--h} " in
	*\ -h\ *|*\ --help\ *)
	echo "$HELP"
	exit;;
esac

#colour settings
CC1='\e[1;37;44m' CC2='\e[1;34;47m' CCE='\e[00m' CSET=
C1=$CC1 C2=$CC2 CE=$CCE
if [[ -t 1 ]]
then 	case " $*" in
	*\ --color=*|*\ --colour=*) 	:;;
	*) 	set -- --color=always "$@";;
	esac
else 	C1= C2= CE=
fi

#cache directory
umask 077  #private
TMPDIR=${TMPDIR:-/tmp}/${0##*/}.${EUID}
[[ -d $TMPDIR ]] || mkdir -p -- "$TMPDIR" &&
printf 'cache: %s\n\n' "$TMPDIR" >&2

#curl / wget
if command -v curl
then 	get() { curl -sL -b emptycookie --insecure --compressed --header "$USER_AGENT" --retry 2 --connect-timeout 240 --max-time 240 -o "$@" ;}
elif command -v wget2
then 	get() { wget2 -q --no-check-certificate --header="$USER_AGENT" -e robots=off --tries=2 --connect-timeout=240 --timeout=240 -O "$@" ;}
else 	get() { wget -q --no-check-certificate --header="$USER_AGENT" -e robots=off --tries=2 --connect-timeout=240 --timeout=240 -O "$@" ;}
fi >/dev/null 2>&1

#markup filter
if command -v w3m
then 	filter() { w3m -dump -T text/html ;}
elif command -v elinks
then 	filter() { elinks -force-html -dump -no-references ;}
elif command -v links
then 	filter() { links -force-html -dump ;}
elif command -v lynx
then 	filter() { lynx -force_html -dump -nolist ;}
else 	filter() { sed '/</{ :loop ;s/<[^<]*>//g ;/</{ N ;b loop } }' ;}
fi >/dev/null 2>&1

#check grep invocation syntax
grep "$@" <<<\  ;(($?<2)) || exit 2;

#load url text file
if ((${#})) && [[ -f ${@:${#}} ]] && [[ -t 0 ]]
then 	exec 0<"${@:${#}}"
	set -- "${@:1:${#} -1}"
fi

#loop through links
while read -r URL || [[ -n $URL ]]
do
	#remove carriage returns
	URL=${URL%%$'\r'} N=$((N+1))
	#job control (bash)
	while JOBS=($(jobs -p)) ;((${#JOBS[@]} > JOBMAX)) ;do 	sleep 0.1 ;done
	#feedback
	printf "${C2}%d${N//?/\\b}${CE}" "$N" >&2

	#async jobs, buffer output
	{	FNAME=${URL:0:128}
		FNAME=${FNAME##*:\/\/} FNAME=${FNAME##www.}
		FNAME=${TMPDIR:=/tmp}/${FNAME//[!a-zA-Z0-9._-]/_}.html

		RESULT=$(
		  if [[ -s $FNAME ]]
		  then  cat -- "$FNAME"
		  elif [[ -d $TMPDIR ]]
		  then  get "$FNAME" "$URL" && cat -- "$FNAME";
		  else  get "-" "$URL"
		  fi | filter | grep "$@"
		) && printf "%s\n${C1}<%s>${CE}\n\n" "$RESULT" "$URL"
	} &
done
wait

