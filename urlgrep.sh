#!/usr/bin/env bash
# urlgrep.sh -- grep full-text urls
# v0.21.5  nov/2023  by mountaineerbr

# Pipe URLs via stdin. Grep takes all positional arguments.

#max simultaneous jobs
JOBMAX=${JOBMAX:-4}
#user agent
USERAGENT="user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36"

SN="${0##*/}"
HELP="NAME
	$SN -- Search Full-Text Web Content from a List of URLs


SYNOPSIS
	$SN [--color=always] [GREP-OPTION...] PATTERN [URL_FILE]
	$SN -h


	Grep full-text content of webpages from a list of URLs read via
	pipe (stdin), or a url text file.


DESCRIPTION
	Read a URL list from stdin (one URL per line), filter HTML con-
	tent by a terminal web browser and run grep. By defaults, run
	$JOBMAX jobs at a time.

	After parsing script options, all other arguments are passed to
	\`grep'. Pipe urls to the script, or set a url file as the last
	command line argument.

	Set environmental variable \$JOBMAX to change maximum simulta-
	neous jobs. Enable colour output with \`--color=always' option.

	Supports curl, wget2 and wget for get programmes and w3m, elinks,
	links, lynx or sed (in that order) for markup filters.

	Carefully crafting the URL list is important as binary files
	will be downloaded and grep should probably throw erros (unless
	option -a is set but grep may return false positive matches).

	It may be easier to download all webpages with wget and them
	run grep on all the webpages if what you are looking for is
	difficult.

	Reaccessing the same urls repeateadly in a short period of time
	may trigger soft blockage from the server. In that case, wait 
	for some time before running this script with those urls.


URL LISTS
	GRAPHICAL INTERFACE

	Use webbrowser bookmarks/history managers to create URL lists.
	Open the manager, select all URLs of interest, copy and paste
	them into a new plain text file, one URL per line and save it.
	There are web browser utilities for generating URL lists of open
	tabs, too.
	
	Firefox
		Menu > Libraries > Bookmarks > Show All Bookmarks
		Menu > Libraries > History > Show All History
			
	Chrome 
		Menu > Bookmarks > Bookmark Manager
		Menu > History > History
		chrome://history


	SHELL FUNCTIONS
	
	Below are some useful shell functions to generate URL lists from
	Mozilla Firefox and Google Chrome.

	Webbrowsers must be closed or a copy of the \`.sqlite' databases
	must be made and used. Set paths to webbrowser databases appro-
	priately. The following functions require \`jq' and \`sqlite3'
	packages.


# ~/.bashrc

#url lists

#firefox user database
FFUSER=\"\$HOME/.mozilla/firefox/XXXXXXXX.default/places.sqlite\"

#google chrome user database
GCUSER=\"\$HOME/.config/google-chrome/Default/History\"

#temp file
TEMPFILE=\"\$HOME/Downloads/urls.sqlite\"

#firefox -- all urls (history, etc)
faurls() { 
	/bin/cp \"\$FFUSER\" \"\$TEMPFILE\" <<<y || return
	sqlite3 \"\$TEMPFILE\" <<<'select url from moz_places where 1;'
	/bin/rm \"\$TEMPFILE\"
}

#firefox -- bookmarks
fburls() { 
	/bin/cp \"\$FFUSER\" \"\$TEMPFILE\" <<<y || return
	sqlite3 \"\$TEMPFILE\" <<<'select url from moz_bookmarks, moz_places where moz_places.id=moz_bookmarks.fk;'
	/bin/rm \"\$TEMPFILE\"
}

#chrome -- all urls (history, etc)
caurls() { 
	/bin/cp \"\$GCUSER\" \"\$TEMPFILE\" <<<y || return
	sqlite3 \"\$TEMPFILE\" <<<'select url from urls where 1;'
	/bin/rm \"\$TEMPFILE\"
}

#chrome -- bookmarks
cburls() {
	jq -r '..|.url? //empty' \"\$HOME/.config/google-chrome/Default/Bookmarks\"
}

#url grep (suggestion)
alias ugrep='faurls | tac | $SN --color=always'


PROOF OF CONCEPT
	The current shell script can be summarised in its simplest form
	in the following function:


ugrepfun() {
	while read
	do 	curl -s \"\$REPLY\" | grep \"\$@\" && echo \">>>\$REPLY\"
	done
}


SEE ALSO
	Simple urlgrep from nriitala (deprecated):
	<https://gist.github.com/nriitala/6110899>

	Perl URLgrep (deprecated):
	<https://github.com/roinfogath/urlgrep>
	<https://code.google.com/archive/p/urlgrep/>


WARRANTY
	This programme/script is Free Software and is licensed under the
	GNU General Public License v3 or better and is distributed with-
	out support or bug corrections.


USAGE EXAMPLES
	I.   Grep a single URL full text.

		$ echo www.example.com | $SN --color=always illustrative


	II.  Cat URL file and pipe to $SN to run grep on those URLs.

		$ cat urlList.txt | $SN -i -e linux
	

	III. Run shell funtion to generate a list of history URLs from
	     Firefox and grep them.

		$ faurls | $SN -C2 -E -e 'forgotten reference' -e 'important stuff'


SCRIPT OPTIONS
	--color=always
		Enable coloured output.
	-h, --help
		Print help."


#help?
[[ $# -eq 0 ]] && {
	sed -n '/^USAGE/,$ p' <<<"$HELP" ;exit 2
}
[[ $1 = -?(-)[Hh]* ]] && {
	echo "$HELP" ;exit
}
#colours
[[ -t 1 && " $* " = *\ --colo?(u)r=always\ * ]] && {
	C1='\e[1;37;44m' C2='\e[1;34;47m' EC='\e[00m'
}

#curl or wget
if command -v curl
then 	get() { curl -sL -b emptycookie --insecure --compressed --header "$USERAGENT" --retry 2 --connect-timeout 240 --max-time 240 "$@" ;}
elif command -v wget2
then 	get() { wget2 -q -O- --no-check-certificate --header="$USERAGENT" -e robots=off --tries=2 --connect-timeout=240 --timeout=240 "$@" ;}
else 	get() { wget -q -O- --no-check-certificate --header="$USERAGENT" -e robots=off --tries=2 --connect-timeout=240 --timeout=240 "$@" ;}
fi >/dev/null

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
fi >/dev/null

#check for grep errors
grep "$@" <<<\  ;(($?<2)) || exit 2

#load urls from last file argument
if ((${#})) && [[ -f ${@:${#}} ]] && [[ -t 0 ]]
then 	exec 0<"${@:${#}}"; set -- "${@:1:${#}-1}";
fi

#loop through links
while read -r URL
do
	#remove carriage returns and increment counter
	URL="${URL//$'\r'}" N=$((N+1))
	#job control (bash)
	while JOBS=($(jobs -p)) ;((${#JOBS[@]} > JOBMAX)) ;do 	sleep 0.1 ;done
	#feedback
	printf "${C2}%d${EC}\r" "$N" >&2

	#async jobs, buffer output
	{
		RESULT=$(get "$URL" | filter | grep "$@") &&
		printf "%s\n${C1}>>>%s${EC}\n\n" "$RESULT" "$URL"
	} &
done
wait

