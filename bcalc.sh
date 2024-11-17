#!/usr/bin/env bash
# bcalc.sh -- shell maths wrapper
# v0.16.11  feb/2023  by mountaineerbr

#record file path (environment, optional defaults)
BCRECFILE="${BCRECFILE:-"$HOME/.bcalc_record.tsv"}"

#extensions file path (environment, optional)
BCEXTFILE="${BCEXTFILE:-unset}"

#special variable for result retrieval from record file
BCHOLD=res

#scale
BCSCALE=16

#max bc result line length
export BC_LINE_LENGTH=10000
#gnu extension accepts `0' to disable line warping

#script name
SN="${0##*/}"

#man page
HELP_LINES="NAME
	$SN -- Shell Maths Wrapper


SYNOPSIS
	$SN  [-,.efltvvz] [-NUM] EXPRESSION
	$SN  -n [INDEX] TEXT
	$SN  -r [NUM] [MAXWIDTH]
	$SN  [-eehrrRV]


DESCRIPTION
	This script warps shell calculator (bc) and Zsh/Ksh93 maths eval-
	uation and adds some useful features.

	A simple input EXPRESSION can be set as positional parameter or
	sent through stdin, otherwise prints last result from record file.

	If a file with historical records is available, special variables
	can be replaced with results from former operations. Data is stored
	as tab separated values (tsv) at \`${BCRECFILE}'.
	Set -f to disable use of record file.

	Special variables \`${BCHOLD}' or \`${BCHOLD}0' will be changed to the last re-
	sult, however \`${BCHOLD}1' and so forth will be changed to the specified
	result index. The result index number is the same as line number
	in the record file. Defaults special variable \`${BCHOLD}'. Check result
	index with options -rv.

	Printing scale can be set with -NUM and reset with \`--'. Scale of
	floating point numbers are dependent on user input for all opera-
	tions except division in bc. Defaults scale is ${BCSCALE}.

	In Zsh/Ksh maths, floating point evaluation is performed automati-
	cally depending on user input. Note that \`3' is an integer while
	\`3.' is a floating point number. An internal double-precision
	(double C type) representation of numbers is kept and expression
	\`3/4' evaluates to \`.75' rather than \`0'.

	Note that this script sets Zsh FORCE_FLOAT and results will be
	converted back to the closest decimal notation from the internal
	double-point. See BUGS section for information about Zsh maths
	limits.

	Option -n adds notes to record file entries. If the first posi-
	tional argument after this option is an INDEX number, adds note
	to that entry, otherwise adds to the last record entry.

	Option -l loads bc mathlib. Option -e loads extension file (see
	ENVIRONMENT section) or Zshell mathfunc module. Option -e also
	disables defaults scale setting, rounding and trimming of insig-
	nificant zeroes.


DECIMAL SEPARATOR AND THOUSANDS GROUPING
	Bc and Zshell maths only accept dot (.) as input decimal separator
	(defaults). Set option \`-.' for dot (.) as input decimal separator
	(and removal of all commas) or \`-,' to set it as comma (,) instead
	(and removal all dots). Beware that some bc and Zsh functions may
	use comma as operator.

	Setting \`-..' means input and output decimal separators should be
	dots (.). Rather, setting \`-.,' means input decimal separator is
	a dot (.) but output should be printed with decimal separator as
	comma (,).

	Option -t prints output with thousands grouping while option -oNUM
	print a number with comma dividers using given spacing NUM. Beware
	shell-specific output length and scale limitations when using these
	options.


	Examples
	Option -,
		(input) 	    (internal) 	    (output)
		1.234.567,00 	--> 1234567.00 	--> 1234567,00

	Option -.,
		(input) 	    (internal) 	    (output)
		1,234,567.00 	--> 1234567.00 	--> 1234567,00


	Option -t
		(input) 	    (output)
		1234567.00 	--> 1,234,567.00


ENVIRONMENT
	BCRECFILE
		Record (history) file path, defaults=\"$BCRECFILE\".

	BCEXTFILE
		Extensions file path for bc, defaults=\"$BCEXTFILE\".
	
	LC_NUMERIC
	LC_ALL
		Affects locale related numeric formats, such as thousands
		delimiter, decimal delimiter. Note that C/POSIX cannot
		effect thousand grouping.


SHELL INTERPRETERS
	This script code is compatible with Bash, Zsh and Ksh93 maths.


SEE ALSO
	BC STANDARD FUNCTIONS and BC MATH LIBRARY
		Check \`man bc' and \`info bc'

	BC EXTENSIONS
		<http://x-bc.sourceforge.net/scientific_constants.bc>
		<http://x-bc.sourceforge.net/extensions.bc>
		<http://www.pixelbeat.org/scripts/bc>
		<http://phodd.net/gnu-bc/>
		<https://github.com/mountaineerbr/scripts>

	ZSHELL MATHFUNC MODULE
		Section \`Mathematical Functions' in zshcontrib(1)
		<https://www.lahey.com/float.htm>


WARRANTY
	This programme is licensed under GPLv3 and above. It is distrib-
	uted without support or bug corrections.

	Tested with Bash 5.0, Zsh 5.8 and Ksh93. Requires GNU coreutils.

	If useful, please consider sending feedback!  =)


BUGS
	Only the last result of multiple operations may be printed and
	recorded, but multiline input is generally not supported.

	In double-point maths, numbers are truncated after 16 digits of
	length (includes the decimal part) and precision is limited to
	a maximum of 16 decimal plates.


USAGE EXAMPLES
	(I)   Equation escaping

		$ $SN '(-20-20)/2'
		
		$ $SN \\(20*20\\)/2

		$ $SN -- -3+30


	      Zshell precommand noglob

		$ noglob $SN (20*20)/2


	(II)  Bc syntax to define reusable parameters within 
	      expression, note variables must be _lowercase_

		$ $SN 'a=8; dog=2; cat=dog; a/(cat+dog)'


		In Zsh, one can set environment variables

		$ export dog=2 cat=3
		$ $SN -z dog+cat

		
	(III) Setting scale to two decimal plates

		$ $SN -2 1/3
		
		$ echo 0.333333333 | $SN -2


	      Grouping thousands in result

		$ $SN -t 100000000

		$ $SN -o 3 100000000


	      Bc read the following syntax in EXPRESSION for setting scale

		$ $SN 'scale=2; EXPRESSION'


	(IV)  Loading bc extensions

		$ $SN -e 'ln(0.3)'   #natural log function

		$ $SN -e 0.234*na    #na is Avogadro number


	(V)   Adding notes to record file entries (may need ecaping)

		$ $SN -n '<This is added to last entry; \$scape w||*ird ch&r& & >'
	
		$ $SN -n 3 This note is for record index 3.
		

OPTIONS
	MISCELLANEOUS
	-z 	  Run script with Zsh.
	-h 	  Print this help page.
	-vv 	  Verbose.
	-V 	  Print script version.
	
	EXTENSIONS
	-e 	  Load bc extensions or Zsh mathfunc module.
	-ee 	  Print bc extension file (if available).
	-l 	  Set bc mathlib or Zsh mathfunc module.

	RECORD FILE
	-f 	  Disable use of record file.
	-n [INDEX] TEXT
		  Add note to record INDEX or to last record entry.
	-r [NUM] [MAXWIDTH]
		  Pretty-print last NUM record entry (def=10).
	-rr 	  Print raw record with record entry index.
	-R 	  Edit with \$VISUAL or \$EDITOR (def=vi).
	
	FORMATTING
	-, 	  Set decimal separator of input/output as (,) comma.
	-. 	  Set decimal separator of input/output as (.) dot.
	-NUM 	  Scale, decimal plates (def=$BCSCALE).
	-o NUM 	  Print result with comma dividers using given spacing.
	-t 	  Print thousands grouping in result."


#bc formatting functions
BCFUN="/* Round argument 'x' to 'd' digits */
define round_(x, d) {
	auto r, s
	if(0 > x) {
		return -round_(-x, d)
	}
	r = x + 0.5*10^-d
	s = scale
	scale = d
	r = r*10/10
	scale = s  
	return r
};
/* Serge3leo - https://stackoverflow.com/questions/26861118/rounding-numbers-with-bc-in-bash
 * MetroEast - https://askubuntu.com/questions/179898/how-to-round-decimals-using-bc-in-bash
 */
/* Truncate trailing zeroes */
define trunc_(x){auto os;os=scale;for(scale=0;scale<=os;scale++)if(x==x/1){x/=1;scale=os;return x}}
/* http://phodd.net/gnu-bc/bcfaq.html
 */
/* workhorse function for the below */
define comma_(x,gp) {
	t=x%gp
	if(x>=gp){
		t+=comma_(x/gp,gp);print \",\"
		for(gp/=obase;gp>=obase;gp/=obase)if(t<gp)print 0
	}
	print t;return 0
};
/* Print a number with comma dividers using given spacing */
/*  e.g. commaprint(1222333, 3) prints 1,222,333 */
define commaprint_(x,g){
	auto os,sign,xdec,xint;
	if(g<1)g=1
	sign=1;if(x<0){sign=-1;x=-x}
	os=scale;scale=0

	/* floating point hack */
	xdec =  x - (x/1);    /* decimal */
	xint = (x - xdec)/1;  /* integer */
	if(xdec>0) x = xint;

	if(sign<0)print \"-\"
	x+=comma_(x,obase^(g/1)); if(xdec>0) print xdec;
	scale=os;return sign*(x+xdec)
};
/* http://phodd.net/gnu-bc/code/output_formatting.bc
 */
"


#functions
#calculators
calcf()
{
	local eq scl var
	eq="${1%;}"
	[[ -n ${eq// } ]] || return
	scl=${OPTS:-$BCSCALE} ;((OPTT)) && scl=${OPTS:-2}

	if [[ -n $ZSH_VERSION$KSH_VERSION ]]
	then 	if [[ -n $ZSH_VERSION ]]
		then 	((OPTE+OPTL)) && zmodload zsh/mathfunc
			setopt LOCAL_OPTIONS FORCE_FLOAT
		fi
		typeset -F ${OPTS:-$BCSCALE} eq
		if ((OPTT))
		then 	printf "%'.*f\n" $scl $eq
		else 	print $eq
		fi
	else 	if ((!OPTE))
		then 	bc ${OPTL:+-l} <<-! | { 	IFS=$'\n' read -d'\0' var var var var ;echo ${var##*$'\n'} ;}
				$BCFUN;
				scale = $scl + 1;
				$eq / 1;
				if($scl+1==scale) round_( last , scale-1 ) else last;
				if(${OPTS:-0}<1)  trunc_( last ) else last;
				if(${OPTT:-0}>0)  dummy = commaprint_( last , ${OPTT_ARG:-3} ) else last;
			!
			return ${PIPESTATUS[0]:-${pipestatus[1]}}
		elif ((OPTE)) && [[ -n $OPTS ]]
		then 	eq="scale = $scl; $eq / 1;"
		fi
		bc ${OPTL:+-l} <<<"$eq"
	fi
}

#-n add note to record file
notef()
{
	local text num
	text="$*" text="${text//[$'\t\n']/ }"
	[[ $text =~ ^\ *[0-9]+\ * ]] ;[[ -n $KSH_VERSION ]] && MATCH="${.sh.match}"
	num="${MATCH:-${BASH_REMATCH[0]}}" text="${text#$num}" text="${text//\//\\/}"
	[[ $text =~ ^\ * ]]
	sed -i -e "${num:-$} s/ *$/ ${text#"${MATCH:-${BASH_REMATCH[0]}}"}/ ;${num:-$} s/"$'\t'" */"$'\t'"/g" "$BCRECFILE"
}
#https://superuser.com/questions/781558/sed-insert-file-before-last-line
#http://www.yourownlinux.com/2015/04/sed-command-in-linux-append-and-insert-lines-to-file.html

#print or edit record file
#usage: precff [NUM] [MAXWIDTH]
#where NUM is the number of entries to be printed
precff()
{
	local lines truncate
	((${1:-0})) && lines="$1"
	truncate="$2"  #max width

	#edit record file
	if ((OPTP<0))
	then 	command "${VISUAL:-${EDITOR:-vi}}" -- "$BCRECFILE"
	#generate record file table
	elif ((OPTP==1))
	then 	((${truncate:-0}>10 && ${truncate:-600}<600)) || truncate=40
		nl -w1 -ba -- "$BCRECFILE" | tail -n"${lines:-10}" \
		| sed -r -e "s/([^\t]{0,${truncate}})[^\t]*/\1/g" -e 's/^(([^\t]*\t){2})([^\t]*)\t/\1{ \3 }\t/' \
		| if command column --help >/dev/null 2>&1 ;then 	column -ets$'\t' -NIND,RESULT,EXPRESSION,DATE,NOTE ;else 	column -ts$'\t' ;fi \
		| less -S
	#print raw record file
	elif ((OPTP))
	then 	if ((lines))
		then 	nl -ba -- "$BCRECFILE" | tail -n $lines
		else 	nl -ba -- "$BCRECFILE"
		fi
	fi
	echo "$BCRECFILE" >&2
}


#parse options
while getopts ,.0123456789efhlno:rRtvVz- opt
do 	case $opt in
		#change input/output decimal separator
		,) 	OPTDEC=${OPTDEC:0:1}, ;;
		#change input/output decimal separator
		\.) 	OPTDEC=${OPTDEC:0:1}. ;;
		#scale
		[0-9]) 	OPTS="$OPTS$opt" ;;
		#reset scale
		-) 	OPTS= ;;
		#load or print bc extensions
		e) 	[[ -e $BCEXTFILE ]] && { 	BC_ENV_ARGS="$BCEXTFILE" ;export BC_ENV_ARGS ;}
			((OPTE++)) && { 	cat -- "$BCEXTFILE" ; exit ;}
			OPTL=1 ;;
		#bc mathlib
		l) 	OPTL=1 ;;
		#disable use record file
		f) 	unset BCRECFILE ;;
		#print help
		h) 	echo "$HELP_LINES" ;exit ;;
		#add note to record
		n) 	((++OPTN)) ;;
		#print record
		r) 	((++OPTP)) ;;
		#edit record
		R) 	OPTP=-100 ;;
		#print a number with comma dividers using given spacing
		o) 	[[ -n $BASH_VERSION ]] || echo "warning: option \`-o' only works with \`\`bc''" >&2
			((OPTT_ARG=OPTARG)) || { 	echo "error: bad argument for option \`-o' -- $OPTARG" >&2 ;exit 1 ;}
			OPTT=1 ;;
		#thousand separator
		t) 	OPTT=1 ;;
		#verbose
		v) 	((++OPTV)) ;;
		#print script version
		V) 	echo "${ZSH_VERSION:+Zsh }${ZSH_VERSION}${BASH_VERSION:+Bash }${BASH_VERSION}${KSH_VERSION:+Ksh }${KSH_VERSION}" 
			grep -m1 '^# v' "$0"
			exit ;;
		#try to run script with zsh
		z) 	if [[ -z $ZSH_VERSION ]]
			then 	env zsh "$0" "$@" ;exit
			fi ;;
		#illegal option
		\?) 	exit 1 ;;
	esac
done
shift $((OPTIND -1))

[[ -n $KSH_VERSION ]] && local() { 	unset "$@" ;}

EQ="$*"
[[ ! -t 0 && $#+OPTN+OPTP -eq 0 ]] && EQ=$(</dev/stdin)  #stdin input
EQ_ORIG="$EQ" EQ="${EQ%;}" EQ="${EQ//[$'\t']/ }"


#record file special vars and options
if [[ -e $BCRECFILE ]]
then 	#add note to record
	if ((OPTN))
	then 	notef "$*" ;exit
	#print or edit record file
	elif ((OPTP))
	then 	precff "$@" ;exit
	fi
	
	#get last record index
	LASTIND=$(wc -l <"$BCRECFILE")
	#change special variable to corresponding record, or retrieve last record if $EQ is empty
	WORDANCHOR='[^a-zA-Z0-9_]'
	while [[ ${EQ:=$BCHOLD} =~ $WORDANCHOR${BCHOLD:-@%@%}[0-9]*$WORDANCHOR ||
		 ${EQ:=$BCHOLD} =~ $WORDANCHOR${BCHOLD:-@%@%}[0-9]*$ ||
		 ${EQ:=$BCHOLD} =~ ^${BCHOLD:-@%@%}[0-9]*$WORDANCHOR ||
		 ${EQ:=$BCHOLD} =~ ^${BCHOLD:-@%@%}[0-9]*$ ]]
	do 	[[ -n $KSH_VERSION ]] && MATCH="${.sh.match}"
		subeq="${MATCH:-${BASH_REMATCH[0]}}" eqvar="$subeq"
		eqvar="${eqvar#$WORDANCHOR}" eqvar="${eqvar%$WORDANCHOR}"
		eqind="${eqvar//[^0-9]}"
		aleft="${subeq%%"$eqvar"*}" aright="${subeq##*"$eqvar"}"
		((eqind)) || eqind=$LASTIND
		((eqind > LASTIND)) && { 	echo "err: invalid index reference -- $eqvar" >&2 ;exit 1 ;}
		recvar=$(awk "NR == $eqind { 	print \$1 }" "$BCRECFILE")

		recvar="${recvar##*;}"
		[[ ${EQ// } = "${eqvar:-@%@%}" ]] && SIMPLEVAREQ=1 LASTIND=$eqind
		EQ="${EQ//"$aleft$eqvar$aright"/$aleft$recvar$aright}" ;[[ -n $EQ ]] || exit
	done  #bash3 introduces regex operator
	unset subeq eqvar eqind aright aleft recvar
elif ((OPTN+OPTP))
then 	echo "$SN: err -- record file not available" >&2 ;exit 1
fi

#-. dot is input decimal separator
if [[ $OPTDEC = .* ]]
then 	EQ="${EQ//,}"
#-, comma is input decimal separator
elif [[ $OPTDEC = ,* ]]
then 	EQ="${EQ//.}" EQ="${EQ//,/.}"
fi

#checks
[[ -n $ZSH_VERSION$KSH_VERSION ]] && ((OPTS>16)) &&     echo "warning: Zsh maximum precision is 16 plates" >&2
((OPTV>1)) && [[ -z $OPTS ]] &&           echo "defaults scale -- $BCSCALE" >&2
((OPTV>1)) && [[ $EQ != "$EQ_ORIG" ]] && echo "input change   -- $EQ" >&2

#calculate expression result
RES=$(calcf "$EQ") && [[ -n $RES ]] || exit

#print to record file
#TSV: result, expression, date and note
timestamp=$(printf '%(%Y-%m-%dT%H:%M:%S%z)T' ${BASH_VERSION:+-1} 2>/dev/null \
	|| { 	zmodload -aF zsh/datetime b:strftime && strftime '%Y-%m-%dT%H:%M:%S%z' ;} 2>/dev/null \
	|| date -Iseconds)
prres="${RES//,}" prres="${prres//$'\n'/;}"
recordout="$prres"$'\t'"${EQ//$'\n'/;}"$'\t'"$timestamp"$'\t'
if [[ -n $BCRECFILE ]]
then 	[[ -e $BCRECFILE ]] && 
	IFS=$'\t' read -r lastres lasteq lastdate lastnote < <(tail -1 "$BCRECFILE") 
	if [[ $prres != "$lastres" || ${EQ//[$IFS;]} != "${lasteq//[$IFS;]}" ]] && ((!SIMPLEVAREQ))
	then 	echo "$recordout" >>"$BCRECFILE" ;((++LASTIND))
	fi
fi
unset prres recordout lastres lasteq lastdate lastnote timestamp

#trim trailing zeroes, skip if -es
if [[ -n $ZSH_VERSION$KSH_VERSION ]] && [[ -z $OPTE$OPTS ]]
then 	if [[ $RES = *[.]*[!0]${RES##*[!0]} ]]
	then 	RES="${RES%${RES##*[!0]}}"
	elif [[ $RES = *[.]${RES##*[!0]} ]]
	then 	RES="${RES%.0*}"
	fi
fi

#swap output decimal and thousands delimiters
[[ $OPTDEC = ?, || $OPTDEC = , ]] && RES="${RES//./@}" RES="${RES//,/.}" RES="${RES//@/,}"
#print special variable index
((OPTV && LASTIND)) && RES="$RES"$'\t'"#$LASTIND#"

echo "$RES"
