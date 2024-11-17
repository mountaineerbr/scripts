#!/usr/bin/env bash
#!/usr/bin/env zsh
# grep.sh  --  grep with shell built-ins
# v0.4.9  feb/2023  by mountaineerbr

#defaults
#script name
SN="${0##*/}"

#colours
COLOUR1='\e[3;35;40m'  #PURPLE
COLOUR2='\e[2;36;40m'  #SEAGREEN
COLOUR3='\e[1;31;40m'  #BOLDRED
COLOUR4='\e[3;32;40m'  #GREEN
NC='\e[m'              #NO COLOUR

#wild cards
DEFSTAR=\*
DEFANCHORL=\^
DEFANCHORR=\$
DEFANCHORWORD='[!a-zA-Z0-9_]'
DEFANCHORWORDEL='(^|[^a-zA-Z0-9_])'
DEFANCHORWORDER='([^a-zA-Z0-9_]|$)'
ANCHORWORDELR='[^a-zA-Z0-9_]'

#minimum length of matches (chars)
#allowed to be painted in regex mode
REGEXMINLEN=2

#set fixed locale
#export LC_NUMERIC=C

#help page
HELP="NAME
	$SN - Grep with shell built-ins


SYNOPSIS
	$SN [OPTION...] PATTERN [FILE...]
	$SN [OPTION...] -e PATTERN ... [FILE...]


DESCRIPTION
	Read FILES or stdin and performs pattern matching. Set multiple
	PATTERNS with -e. A line is printed when that matches a pattern.

	By defaults, interpret PATTERN as POSIX EXTENDED REGEX. Please
	note that some operators for EXTENDED REGEX need backslash escap-
	ing to activate, otherwise they have got no special meaning. Quot-
	ing example: '\\(foo\\|bar\\)' and 'baz.\\{1,5\\}'.

	Set option -g for EXTENDED GLOBBING syntax of PATTERNS. Option
	-g adds star globs around *PATTERN* whereas -gg does not add
	these automatically and is functionally the same as -gx. Option
	-@ enables KSH_GLOB in Zsh and also sets -g once. Extended glob
	operators are active by defaults. Quote characters with backslash
	to treat them as literals when needed.

	Set option -P to interpret PATTERNS as Perl-compatible regular
	expressions. This option requires zsh/pcre module.

	Set option -k to paint matches if output is not redirected (auto-
	matically detected) or set -kk to force.

	This script uses shell builtins only and is compatible with Bash
	and Zshell. It is not supposed to compete with Grep, it is rather
	a tool for studying shell scripting. Recently, code readability
	was exchange for speed improvements.

	Refer to man pages of REGULAR EXPRESSIONS, GLOBBING PATTERNS,
	EXTENDED GLOBBING, KSH-LIKE GLOB OPERATORS, ZSH GLOB QUALIFIERS
	and ZSH GLOBBING FLAGS to understand better what shell facilities
	this script warps.


ENVIRONMENT
	LC_ALL
	       This variable overrides the value of the \`LANG' variable
	       and the value of any of the other variables starting with
	       \`LC_'.

	LC_COLLATE
	       This variable determines the locale category for character
	       collation information within ranges in glob brackets and
	       for sorting.

	LC_CTYPE
	       This variable determines the locale category for character
	       handling functions.


SEE ALSO
	Globbing and Regex: So Similar, So Different
	<https://www.linuxjournal.com/content/globbing-and-regex-so-similar-so-different>

	A Brief Introduction to Regular Expressions
	<https://tldp.org/LDP/abs/html/x17129.html>

	GNU Grep source code (GNU Savannah)
	<https://git.savannah.gnu.org/cgit/grep.git/tree/src/grep.c>

	BSD Grep source code (FreeBSD SVN)
	<https://svnweb.freebsd.org/base/stable/12/usr.bin/grep/>

	RIP Grep (development tips)
	<https://blog.burntsushi.net/ripgrep/>

	Man pages
	glob(1), test(1), grep(1), regex(3)
	bash(1), see Pattern Matching and extglob option
	zshexpn(1), see Glob Operators, Globbing Flags, Approximate Matching
	and Glob Qualifiers


WARRANTY
	Licensed under the GNU Public License v3 or better and is
	distributed without support or bug corrections.

	This script requires Bash or Zsh to work properly.

	Please consider sending feedback!  =)


BUGS
	Option -k may paint only some matches or may paint matches incom-
	pletely; with -g, only the outermost two matches of each line may
	be painted; with -gi painting is disabled; with -E, very short
	matches (less or equal to $REGEXMINLEN chars) may skip painting.

	Option -k may expand some backspace-escaped strings from input,
	such as escaped colour code sequences and \\n.


OPTIONS
	Pattern Syntax
	-@      Enable Ksh extended glob operators in Zsh and set -g.
	-E, -r  Interpret PATTERNS as extended regex (ERE) (defaults).
	-F      Interpret PATTERNS as fixed strings.
	-g      Interpret PATTERNS as globbing strings.
	-gg     Bare glob test, same as -g but no glob stars around PATTERN
		are added automatically (functionally same as -gx).
	-P 	Interpret PATTERNS as Perl-compatible regex (PCRE);
		requires zsh/pcre module.

	Matching Control
	-e PATTERN
	        Pattern to match.
	-i, -y  Case insensitive match.
	-v      Select non-matching lines.
	-w      Match whole words only.
	-x      Match whole line only.

	General Output Control
	-c      Print only count of matching lines.
	-k      Colorise output (auto), set twice to force.
	-m NUM  Maximum NUM results to print.
	-q      Quiet, exit with zero on first match found.

	Output Line Prefix Control
	-n      Add line number prefix of matched lines.
	-t      Suppress file name prefix for each matched line.
	-T      Print file name for each match.

	Miscellaneous
	-h      Print this help page.
	-V      Print script version."


#parse options
while getopts @cEe:FgGHhiyKkm:nPqrtTvVxwz c
do
	case $c in
		#globbing pattern matching
		#enables KSH_GLOB in zsh
		@) OPTAT=1 ;((OPTG)) || OPTG=1 ;unset OPTF OPTE OPTP ;;
		#count matched lines
		c) OPTC=1 ;;
		#extended regex
		E|r) OPTE=1 ;unset OPTG OPTAT OPTF ;;
		e)
			#search arguments
			if (( ${#PATTERNARPRE[@]} ))
			then PATTERNARPRE=( "${PATTERNARPRE[@]}" "$OPTARG" ) 
			else PATTERNARPRE=( "$OPTARG" )
			fi ;;
		#fixed strings
		F) OPTF=1 ;unset OPTG OPTAT OPTE OPTP ;;
		#same as -gg
		G) OPTG=2 ;;
		#globbing pattern matching
		g) ((++OPTG)) ;unset OPTF OPTE OPTP ;;
		#toggle print filename
		H) OPTH=1 ;;
		#help
		h) echo "$HELP" ;exit 0 ;;
		#case-insensitive search
		i|y) ((++OPTI)) ;;
		#force colour
		K) OPTK=2 ;;
		#paint matches
		k) ((++OPTK)) ;;
		#max results
		m) MAXMATCH=$OPTARG ;;
		#print match line number
		n) OPTN=1 ;;
		#PCRE
		P) OPTE=1 OPTP=1 ;unset OPTG OPTAT OPTF ;;
		#quiet
		q) OPTQ=1 ;;
		#do not print file name
		t) OPTT=2 ;;
		#print file name
		T) OPTT=1 ;;
		#invert match
		v) OPTV=1 ;;
		V)
			#script version
			while read
			do if [[ "$REPLY" = \#\ v* ]] ;then echo "$REPLY" ;exit ;fi
			done <"$0" ;;
		#whole line match
		x) OPTX=1 ;;
		#whole word match
		w) OPTW=1 ;;
		#try to change interpreter to zsh
		z) [[ -n $ZSH_VERSION ]] || { zsh "$0" "$@" ;exit ;} ;;
		#illegal option
		?) exit 1 ;;
	esac
done
shift $((OPTIND - 1))
unset c

#shell options
if [[ -n $ZSH_VERSION ]]
then
	#set zsh opts
	setopt GLOBSUBST EXTENDED_GLOB ${OPTAT+KSH_GLOB} ${OPTP+RE_MATCH_PCRE} ${OPTI+NOCASE_MATCH}
else 
	#set bash opts
	shopt -s extglob ${OPTI+nocasematch}
	((OPTP)) && { echo "$SN: err  -- option -P requires Zsh" >&2 ;exit 1 ;}
fi

#colour (paint matches)?
if [[ "$OPTK" -lt 2 && ( "$OPTK" -eq 0 || ! -t 1 ) ]]
then unset COLOUR1 COLOUR2 COLOUR3 COLOUR4 NC OPTK
fi

#echoresultf printf string
STRFILE="${COLOUR1}%s${COLOUR2}:${NC}"
#-n line number colour
STRLNUM="${COLOUR4}%s${COLOUR2}:${NC}"

#hack -ii print matched line in uppercase (with -g)
((OPTI>1 && OPTK && OPTG)) && typeset -u PATTERN LINE

#set star globs around *PATTERN* by defaults (globbing test only)
((OPTG>1)) || STAR=$DEFSTAR

#whole line match
((OPTX)) && {
	#whole-line match
	ANCHORL=$DEFANCHORL
	ANCHORR=$DEFANCHORR
	unset STAR
}

#whole word match
((OPTW)) && {
	ANCHORWORD=$DEFANCHORWORD
	ANCHORWORDEL=$DEFANCHORWORDEL
	ANCHORWORDER=$DEFANCHORWORDER
}

#declare test function
#-g globbing test + -w
if ((OPTG && OPTW))
then
	#extended globbing test + -w
	#invert matches?
	if ((OPTV))
	then
		testf()
		{
			[[ "$STRING" != ${STAR}${ANCHORWORD}${PATTERN}${ANCHORWORD}${STAR}
			|| "$STRING" != ${PATTERN}${ANCHORWORD}${STAR}
			|| "$STRING" != ${STAR}${ANCHORWORD}${PATTERN}
			|| "$STRING" != ${PATTERN} ]]
		}
	else
		testf()
		{
			[[ "$STRING" = ${STAR}${ANCHORWORD}${PATTERN}${ANCHORWORD}${STAR}
			|| "$STRING" = ${PATTERN}${ANCHORWORD}${STAR}
			|| "$STRING" = ${STAR}${ANCHORWORD}${PATTERN}
			|| "$STRING" = ${PATTERN} ]]
		}
	fi
#-g globbing test
elif ((OPTG))
then
	#extended globbing test
	if ((OPTV))
	then testf() { [[ "$STRING" != ${STAR}${PATTERN}${STAR} ]] ;}
	else testf() { [[ "$STRING" = ${STAR}${PATTERN}${STAR} ]] ;}
	fi
#-E regex test (defaults)
else
	#posix extended regex test
	if ((OPTV))
	then testf() { [[ ! "$STRING" =~ ${ANCHORL}${ANCHORWORDEL}${PATTERN}${ANCHORWORDER}${ANCHORR} ]] ;}
	else testf() { [[ "$STRING" =~ ${ANCHORL}${ANCHORWORDEL}${PATTERN}${ANCHORWORDER}${ANCHORR} ]] ;}
	fi
fi


#more than one argument? is file?
while (($#))
do
	#is last positional argument a file?
	if [[ -e "${@: -1}" && ! -d "${@: -1}" ]]
	then
		if ((${#FILEAR[@]}))
		then FILEAR=("${@: -1}" "${FILEAR[@]}")
		else FILEAR=("${@: -1}")
		fi
	elif (($#>1))
	then RET=2 ;echo "$SN: no such file -- ${@: -1}" >&2
	else break
	fi
	set -- "${@:1:$(($# - 1))}"
done

#is there any file? is stdin free?
if [[ "${#FILEAR[@]}" -eq 0 && -t 0 ]]
then echo "$SN: err  -- input required" >&2 ;exit ${RET:-1}
fi

#more than one file, or at least one file skipped (RET=2) above?
((${#FILEAR[@]} > 1 || ( RET==2 && ${#FILEAR[@]} ) )) && PRINTFNAME=1

#file name printing
if ((OPTT==1))      #-t print filename
then PRINTFNAME=1
elif ((OPTT==2))    #-T no filename
then PRINTFNAME=0
elif ((OPTH))       #-H toggle default behaviour
then ((PRINTFNAME)) && PRINTFNAME=0 || PRINTFNAME=1
fi

#check positional arguments
((${#PATTERNARPRE[@]}==0)) && {
	if (($#>0))
	then PATTERNARPRE=("$1") ;shift
	elif (($#==0))
	then echo "$SN: err  -- PATTERN required" >&2 ;exit ${RET:-1}
	fi
}

#there should not be anything left
#as positional parameters by now
if (($#))
then echo "$SN: err: not a file -- ${@: -1}" >&2 ;set ;RET=2
fi

#quote patterns 
if ((OPTF))
then
	#-F fixed, quote all chars
	for p in "${PATTERNARPRE[@]}"
	do
		if ((${#PATTERNAR[@]}))
		then PATTERNAR=("${PATTERNAR[@]}" "$(printf %q "$p")" )
		else PATTERNAR=( "$(printf %q "$p")" )
		fi
	done
	#obs: zsh quoting with "${(b)p}" works in this case
	#obs: bash quoting with "${p@Q}" does not work in this case
else
	#just quote spaces with backslash
	for p in "${PATTERNARPRE[@]}"
	do
		if ((${#PATTERNAR[@]}))
		then PATTERNAR=("${PATTERNAR[@]}" "${p// /\\ }" )
		else PATTERNAR=( "${p// /\\ }" )
		fi
	done
fi

#loop through files
for FILE in "${FILEAR[@]:-/dev/stdin}"
do
	[[ "$FILE" = /dev/stdin ]] || exec 0< "$FILE"

	#loop through document
	while IFS=  read -r LINE || [[ -n "$LINE" ]]
	do
		#-i option case-insensitive catches here
		STRING="$LINE"

		#count line numbers
		(( ++LNUM ))

		#loop through PATTERNS
		for PATTERN in "${PATTERNAR[@]}"
		do
			#test for a match in line
			testf || continue

			#count lines with matches, total matches
			(( ++LINEMATCH && ++TOTMATCHES )) ;RET=${RET:-0}

			#-c only count matched lines
			(( OPTC )) && continue
			
			#-q quiet? exit on first match
			(( OPTQ )) && exit

			#print matched line
			#print filename (multiple files)
			((PRINTFNAME)) && printf "$STRFILE" "$FILE"
			#print line number
			((OPTN)) && printf "$STRLNUM" "$LNUM"
			
			#print inverted match lines
			#print raw line if colour opt is not set
			if ((OPTV || OPTK==0 || ( OPTG && OPTI<2 ) ))
			then
				#print raw line
				echo "$LINE"

			#paint matches in line
			#painting matches is by far the longest and most problematic code
			else
				#globbing test
				if ((OPTG))
				then
					#try to paint matches
					linep="$LINE"
					linexr="${linep##*$PATTERN}"  #line right long
					linexl="${linep%%$PATTERN*}"  #line left long
					linexrs="${linep#*$PATTERN}"  #line right short
					linexls="${linep%$PATTERN*}"  #line left short

					
					#is whole-line a match?
					if [[ -z "$linexr$linexl" ]]
					then
						linep="${COLOUR3}${linep}${NC}"

					#if left and right templates are not the same..
					#escape templates and substitute further
					elif
						[[ "$linexr" = "$linep" ]] && unset linexr
						[[ "$linexl" = "$linep" ]] && unset linexl
						[[ "$linexr" != "$linexl" ]]
					then
						if [[ -n $ZSH_VERSION ]]
						then
							#zsh escaping
							#one or more matches?
							if [[ "$linexls" != "$linexl" ]]
							then
								#paint the two outermost matches
								linexm="${linep#${(b)linexl}}"
								linexm="${linexm%${(b)linexr}}"    #line middle

								matchb="${linexm#${(b)linexls#${(b)linexl}}}"
								matcha="${linexm%${(b)linexrs%${(b)linexr}}}"

								linexmm="${linexm#${(b)matcha}}"
								linexmm="${linexmm%${(b)matchb}}"  #line middle middle

								linep="$linexl$COLOUR3$matcha$NC$linexmm$COLOUR3$matchb$NC$linexr"
							else
								#paint a single match
								linep="${linexl}${COLOUR3}${linep#${(b)linexl}}"
								linep="${linep%${(b)linexr}}${NC}${linexr}"
							fi
						else
							#bash escaping
							linexr="${linexr//\\/\\\\}"
							linexl="${linexl//\\/\\\\}"
							linexrs="${linexrs//\\/\\\\}"
							linexls="${linexls//\\/\\\\}"
						
							#one or more matches?
							if [[ "$linexls" != "$linexl" ]]
							then
								#paint the two outermost matches
								linexm="${linep#$linexl}"
								linexm="${linexm%$linexr}"    #line middle

								matchb="${linexm#${linexls#$linexl}}"
								matcha="${linexm%${linexrs%$linexr}}"

								linexmm="${linexm#$matcha}"
								linexmm="${linexmm%$matchb}"  #line middle middle

								linep="$linexl$COLOUR3$matcha$NC$linexmm$COLOUR3$matchb$NC$linexr"
							else
								#paint a single match
								linep="${linexl}${COLOUR3}${linep#$linexl}"
								linep="${linep%$linexr}${NC}${linexr}"
							fi
						fi
					fi

				#regex test
				else
					#try to paint all matches
					linex="$LINE"  linep="$LINE"  firstpass=1

					while
						matchx="${BASH_REMATCH[0]:-$MATCH}"
						((OPTW)) && {
							matchx="${matchx#$ANCHORWORDELR}"
							matchx="${matchx%$ANCHORWORDELR}"
						}
						
						((firstpass)) || {
							((${#BASH_REMATCH[0]} > REGEXMINLEN || ${#MATCH} > REGEXMINLEN)) \
							&& linex="${linex//"$matchx"}" \
							&& [[ -n "$linex" ]] \
							&& STRING="$linex" testf
						}
					do
						linep="${linep//"$matchx"/${COLOUR3}${matchx}${NC}}"
						unset firstpass
					done
				
				fi

				#print coloured line
				echo -e "$linep"
			fi
			unset linep linex linexr linexl linexm matchx firstpass linexrs linexls matcha matchb


			#-m max results set?
			((MAXMATCH && LINEMATCH == MAXMATCH)) && break 2
		done
	done

	
	#-c only print matched line count?
	((OPTC)) && echo "${LINEMATCH:-0}"

	#unset count line numbers
	unset LNUM LINEMATCH
done

exit ${RET:-1}

