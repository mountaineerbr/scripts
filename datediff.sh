#!/usr/bin/env bash
# datediff.sh - Calculate time ranges between dates
# v0.25.1  dec/2024  mountaineerbr  GPLv3+
[[ -n $BASH_VERSION ]] && shopt -s extglob  #bash2.05b+/ksh93u+/zsh5+
[[ -n $ZSH_VERSION  ]] && setopt NO_SH_GLOB KSH_GLOB KSH_ARRAYS SH_WORD_SPLIT GLOB_SUBST

HELP="NAME
	${0##*/} - Calculate time ranges/intervals between dates


SYNOPSIS
	${0##*/} [-Rrttuvvv] [-NUM] [-f\"FMT\"] \"DATE1\" \"DATE2\" [UNIT]
	${0##*/} -FF [-vv] [[DAY_IN_WEEK] [DAY_IN_MONTH]] [START_DATE]
	${0##*/} -eel [-v] YEAR..
	${0##*/} -m [-v] DATE..
	${0##*/} -h


DESCRIPTION
	Calculate time interval (elapsed) between DATE1 and DATE2 in var-
	ious time units. The \`C-code date' programme is optionally run
	to process input dates to the ISO-8601 format.

	Other features include checking if YEAR is leap, printing Easter,
	Carnaval, and Corpus Christi dates on a given YEAR, and the phase
	of the moon at DATE.


	Main Function

	In the main function, \`GNU date' accepts mostly free format human
	readable date strings. If using \`FreeBSD date', input DATE strings
	must be ISO-8601 (\`YYYY-MM-DDThh:mm:ss'), unless option \`-f FMT' is
	set to a new input time format. If \`date programme' is not avail-
	able then input must be formatted as ISO-8601 or UNIX time.

	If DATE is not set, defaults to \`now'. If only one DATE is set,
	the first one is assumed to be \`now' or \`1970'.

	To flag DATE as UNIX time, prepend an at sign \`@' to it or set
	option -r. Stdin input supports one DATE string per line (max two
	lines) or two ISO-8601 DATES separated by space in a single line.
	Input is processed in a best effort basis.


	Main Output

	Output RANGES section displays intervals in different units of
	time (years, or months, or weeks, or days, or hours, or minutes,
	or seconds alone). It also displays a compound time range with
	all the above units into consideration to each other.

	Single UNIT time periods can be displayed in table format -t and
	their scale set with -NUM where NUM is an integer. Result least
	significant digit is subject to rounding. When last positional
	parameter UNIT is exactly one of \`Y', \`MO', \`W', \`D', \`H',
	\`M', or \`S', only a single UNIT interval is printed.

	Output DATES section prints two dates in ISO-8601 format or, if
	option -R is set, RFC-5322 format.

	Option -u sets or prints dates in Coordinated Universal Time (UTC)
	in the main function. This affects the \`C-code date' programme.

	Options -vvv filter the main output layout for specific timeframes.


	Extra Functions

	Option -e prints Easter date for given YEARs (for Western Churches)
	and option -ee also prints Carnaval and Corpus Christi dates.

	Option -l checks if YEAR is leap. Set option -v to decrease ver-
	bose. ISO-8601 system assumes proleptic Gregorian calendar, year
	zero and no leap seconds.

	Option -m prints lunar phase at DATE as \`YYYY[-MM[-DD]]', auto
	expansion takes place on partial DATE input. DATE ought to be UTC
	time. Code snippet adapted from NetHack.

	Option -F prints the date of next Friday the 13th, START_DATE must
	be formated as \`YYYY[-MM[-DD]]'. Set twice to prints the following
	10 matches. Optionally, set day in the week, such as Sunday, and
	day number in month as first and second positional parameters.


	Timezone Offsets

	DATE offsets as per ISO-8601 are supported throughout this script.
	When environment \$TZ is a positive or negative decimal number, such
	as \`UTC+3', it is read as offset. Variable \$TZ with timezone name
	or ID (e.g. \`America/Sao_Paulo') is supported by \`C-code date'.

	This script uses Bash/Ksh arithmetics to perform most time range
	calculations, as long as input is a valid ISO-8601 date format.


	Debug and Test

	Options -d and -dd execute result checks against \`C-code datediff'
	and \`C-code date' programmes. Requires \`datediff.debug.sh'.

	Option -D disables \`C-code date' warping and -DD disables Bash/
	Ksh \`printf %()T' warping, too. This will have the script run and
	process dates with only the shell built-in code instead of trying
	to execute \`C-code date' for date processing and format conversion.


	Project source is hosted at:

	<https://gitlab.com/fenixdragao/shelldatediff>
	<https://github.com/mountaineerbr/shellDatediff>


ENVIRONMENT
 	CFACTOR 	Correction factor used in the lunar phase func-
			tion. Defaults=\"-1892\"

	DATE_CMD 	Path to \`C-code date' programme. GNU, BSD, AST
			and Busybox \`date' are supported.

	TZ 		Offset time. POSIX time zone definition by the
			\$TZ variable takes a different form from ISO-8601
			standards, so that ISO UTC-03 is equivalent to
			setting \$TZ=UTC+03. Only the \`C-code date'
			programme can parse timezone names and IDS.


REFINEMENT RULES
	Some date intervals can be calculated in more than one way depend-
	ing on the logic used in the \`compound time range' display. We
	decided to mimic \`Hroptatyr's datediff' refinement rules as often
	as possible.

	Script error rate of the core code is estimated to be lower than
	one percent after extensive testing with selected and corner-case
	sample dates and times. Check script source code for details.


SEE ALSO
	\`Datediff' from \`dateutils', by Hroptatyr.
	<www.fresse.org/dateutils/>

	\`PDD' from Jarun
	<github.com/jarun/pdd>

	\`AST date' elapsed time option -E
	<github.com/att/ast>

	\`Units' from GNU.
	<https://www.gnu.org/software/units/>

	Do calendrical savants use calculation to answer date questions?
	A functional magnetic resonance imaging study, Cowan and Frith, 2009.
	<https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2677581/#!po=21.1864>

	Calendrical calculation, Dershowitz and Reingold, 1990
	<http://www.cs.tau.ac.il/~nachum/papers/cc-paper.pdf>
	<https://books.google.com.br/books?id=DPbx0-qgXu0C>

	How many days are in a year? Manning, 1997.
	<https://pumas.nasa.gov/files/04_21_97_1.pdf>

	Iana Time zone database
	<https://www.iana.org/time-zones>

	Fun with Date Arithmetic (see replies)
	<https://linuxcommando.blogspot.com/2009/11/fun-with-date-arithmetic.html>

	Tip: Division is but subtractions and multiplication but additions.
	--Lost reference


WARRANTY
	Licensed under the GNU General Public License 3 or better. This
	software is distributed without support or bug corrections. Many
	thanks for all whose advice improved this script from c.u.shell.

	Bash2.05b+, Ksh93 or Zsh is required. \`Bc' or Ksh is required
	for single-unit calculations. FreeBSD12+ or GNU \`date' is
	optionally required.


EXAMPLES
	Leap year check
	${0##*/} -l 2000
	${0##*/} -l {1980..2000}
	echo 2000 | ${0##*/} -l

	Moon phases for January 1996
	${0##*/} -m 1996-01

	Print following Friday, 13th
	${0##*/} -F
	Print following Sunday, 12th after 1999
	${0##*/} -F sun 12 1999

	Single unit time periods
	${0##*/} 2022-03-01T00:00:00 2022-03-01T10:10:10 m  #(m)ins
	${0##*/} '10 years ago'  mo                         #(mo)nths
	${0##*/} 1970-01-01  2000-02-02  y                  #(y)ears

	Time ranges/intervals
	${0##*/} 2020-01-03T14:30:10 2020-12-24T00:00:00
	${0##*/} 0921-04-12 1999-01-31
	echo 1970-01-01 2000-02-02 | ${0##*/} 
	TZ=UTC+3 ${0##*/}  2020-01-03T14:30:10-06  2021-12-30T21:00:10-03:20

	\`GNU date' warping
	${0##*/} 'next monday'
	${0##*/} 2019/6/28  1Aug
	${0##*/} '5min 34seconds'
	${0##*/} 1aug1990-9month now
	${0##*/} -- -2week-3day
	${0##*/} -- \"today + 1day\" @1952292365
	${0##*/} -2 -- '1hour ago 30min ago'
	${0##*/}  today00:00  '12 May 2020 14:50:50'
	${0##*/} '2020-01-01 - 6months' 2020-01-01
	${0##*/} '05 jan 2005' 'now - 43years -13 days'
	${0##*/} -u 2023-01-14T11:20:00Z '2023-01-14T11:20:00Z + 5 hours'
	${0##*/} @1561243015 @1592865415

	\`BSD date' warping
	${0##*/} -f'%m/%d/%Y' 6/28/2019  9/04/1970 
	${0##*/} -r 1561243015 1592865415
	${0##*/}  200002280910.33  0003290010.00
	${0##*/} -- '-v +2d' '-v -3w'


OPTIONS
	Extra Functions
	-e 	Print Western Easter date.
	-ee 	Print Carnaval, Easter and Corpus Christi dates.
	-FF 	Print following Friday the 13th date.
	-h 	Print this help page.
	-l 	Check if YEAR is leap year.
	-m      Print lunar phase at DATE (ISO UTC time).

	Main Function
	-[0-9] 	Set scale for single unit intervals.
	-DDdd 	Debug, check help page.
	-f FMT 	Input time format string (only with BSD \`date').
	-R 	Print human time in RFC-5322 format (verbose).
	-r, -@ 	Input DATES are UNIX times.
	-tt 	Table layout display of single unit intervals.
	-u 	Set or print UTC time instead of local time.
	-vvv 	Verbose level, change print layout of functions."

# TESTING SCRIPTS
# The project is hosted at <https://github.com/mountaineerbr/shellDatediff>.
# Complementary code for testing and a lot more notes are hosted there.
#
# Error rate for the compound range calculation stabilises at about .6%
# of all tested dates. A little over half of the errors is due to
# `C-code datediff' printing results with more than 4 weeks (instead of
# it adding to months). All other differences occur with ``end-of-month
# vs start-of-month'' dates, such as days `29, 30 or 31' of one date
# against days `1, 2 or 3' of the other date.
#
# For example the following dates:
#      ``1988-01-31T07:00:00Z  vs  1988-12-05T11:00:00Z''
# which results differ as:
#      sh =  0Y 2M 4W 3D  4H 0MIN 0S
#      dd =  0y 3m 0w 0d  4h 0min 0s
#
# Because the start date is ``Dec 31st'', one can consider a full month
# count only at ``Apr 30th'' or `Apr 31st' which does not exist but is
# equivalent to ``May 1st''.
#
# Different results from `C-code datediff' in compound range are not
# necessarily errors and may be considered correct because of different
# refinement rules.


#globs
SEP='Tt/.:+-'
EPOCH=1970-01-01T00:00:00
GLOBOPT='@(y|mo|w|d|h|m|s|Y|MO|W|D|H|M|S)'
GLOBUTC='*(+|-)@(?([Uu])[Tt][Cc]|?([Uu])[Cc][Tt]|?([Gg])[Mm][Tt]|Z|z)'  #see bug ``*?(exp)'' in bash2.05b extglob; [UG] are marked optional for another hack in this script 
GLOBTZ="?($GLOBUTC)?(+|-)@(2[0-4]|?([01])[0-9])?(?(:?([0-5])[0-9]|:60)?(:?([0-5])[0-9]|:60)|?(?([0-5])[0-9]|60)?(?([0-5])[0-9]|60))"
GLOBDATE='?(+|-)+([0-9])[/.-]@(1[0-2]|?(0)[1-9])[/.-]@(3[01]|?(0)[1-9]|[12][0-9])'
GLOBTIME="@(2[0-4]|?([01])[0-9]):?(?([0-5])[0-9]|60)?(:?([0-5])[0-9]|:60)?($GLOBTZ)"
#https://www.oreilly.com/library/view/regular-expressions-cookbook/9781449327453/ch04s07.html
#custom support for 24h clock and leap second

DAY_OF_WEEK=(Thursday Friday Saturday Sunday Monday Tuesday Wednesday)
MONTH_OF_YEAR=(January February March April May June July August September October November December)
YEAR_MONTH_DAYS=(31 28 31 30 31 30 31 31 30 31 30 31)
TIME_ISO8601_FMT='%Y-%m-%dT%H:%M:%S%z'
TIME_RFC5322_FMT='%a, %d %b %Y %H:%M:%S %z'
TIME_ISO8601_FMT_PF='%04d-%02d-%02dT%02d:%02d:%02d%.1s%02d:%02d:%02d'
TIME_RFC5322_FMT_PF='%.3s, %02d %.3s %04d %02d:%02d:%02d %.1s%02d:%02d:%02d'
CFACTOR="${CFACTOR--1892}"  #moon phase correction factor


# Choose between GNU/BSD/AST/BUSYBOX date
# datefun.sh [-u|-R|-v[val]|-I[fmt]] [YYYY-MM-DD|@UNIX] [+OUTPUT_FORMAT]
# By defaults, input should be ISO8601 date or UNIX time (append @).
# Option -I `fmt' may be `date', `hours', `minutes' or `seconds' (added in FreeBSD12).
# Setting environment TZ=UTC is equivalent to -u. Accepts only one opt (such as -uIseconds).
function datefun
{
	typeset options input_fmt globtest ar chars start variable_iso
	input_fmt="${INPUT_FMT:-${TIME_ISO8601_FMT%??}}"
	[[ $1 = -[uRIv]* ]] && options="$1" && shift

	#ISO8601 variable length
	globtest="*([$IFS])@($GLOBDATE?([$SEP])?(+([$SEP])$GLOBTIME)|$GLOBTIME)?([$SEP])*([$IFS])"
	if [[ $1 = $globtest && -z $OPTF && -n $ASTDATE$BSDDATE$BUSYDATE ]]  #ISO8601 variable length
	then 	ar=(${1//[$SEP]/ })
		[[ ${1//[$IFS]} = +([0-9])[:]* ]] && start=9 || start=0
		((chars=(${#ar[@]}*2)+(${#ar[@]}-1) , variable_iso=1))
	fi

	if ((BSDDATE))
	then 	if [[ -z $1 ]]
		then 	set --
		elif ((variable_iso))
		then 	${DATE_CMD} ${options} -j -f "${TIME_ISO8601_FMT:$start:$chars}" "${@/$GLOBUTC}" && return
		fi
		if [[ ${1:-+%} != @(+%|@|-f)* && $1${OPTF+x} != +([0-9])?(.[0-9][0-9]) ]]  #[[[[[cc]yy]mm]dd]HH]MM[.ss]
		then 	set -- -f"${input_fmt}" "$@"
		elif [[ $1 = @* ]]
		then 	set -- "-r${1#@}" "${@:2}"
		fi
		${DATE_CMD} ${options} -j "$@"
	elif ((ASTDATE))
	then 	[[ $1 = @(+%|-f)* || $2 = @(+%|-f)* || $options = *-R* ]] ||
			options="$options -f ${TIME_ISO8601_FMT}"
		if [[ $1 = @* ]]
		then 	options="${options} -p %s"
			set -- "${@/@/}"
		elif ((!OPTF)) && [[ $1 != @(+%|-f)* ]] && [[ $2 = @(+%|-f)* ]]
		then 	options="$options -p ${TIME_ISO8601_FMT:$start:$chars}"
		fi
		options="${options/@(-I@(date|hours|minutes|seconds)|-I)}"

		[[ ${1:-+%} != @(+%|-d)* ]] && set -- -d"${1}" "${@:2}"
		${DATE_CMD} ${options} "$@"
	else
		[[ ${1:-+%} != @(+%|-d)* ]] && set -- -d"${1}" "${@:2}"
		if ((BUSYDATE&&variable_iso))
		then 	set -- -D"${TIME_ISO8601_FMT:$start:$chars}" "$@"
		elif ((BUSYDATE&&OPTF))
		then 	set -- -D"${input_fmt}" "$@"
		fi
		[[ $DATE_CMD = *toybox* && $options = *-R* ]] && { 	set -- "$@" +"$TIME_RFC5322_FMT" ;options="${options/-R}" ;}
		${DATE_CMD} ${options} "$@"
	fi
}

#leap fun
function is_leapyear
{
	typeset year
	set -- "${1:-0}";
	((year=10#${1##[+-]}));
	case "$1" in -*) 	year=-$year;; esac;

	((!(year % 4) && (year % 100 || !(year % 400) ) ))
}

#print the maximum number of days of a given month
#usage: month_maxday [MONTH] [YEAR]
#MONTH range 1-12; YEAR cannot be nought.
function month_maxday
{
	typeset month year
	set -- "${1:-1}" "${2:-0}";
	((month=10#${1}));
	((year= 10#${2##[+-]}));
	case "$2" in -*) 	year=-$year;; esac;
	
	if ((month==2)) && is_leapyear $year
	then 	echo 29
	else 	echo ${YEAR_MONTH_DAYS[month-1]}
	fi
}

#number of days in a year, count as leap year only
#if date1's month is before or at February.
function year_days_adj
{
	typeset month year
	set -- "${1:-1}" "${2:-0}";
	((month=10#${1}));
	((year= 10#${2##[+-]}));
	case "$2" in -*) 	year=-$year;; esac;
	
	if ((month<=2)) && is_leapyear $year
	then 	echo 366
	else 	echo 365
	fi
}

#check if input is a pos/neg integer year
function is_year
{
	if [[ $1 = ?(-)+([0-9]) ]]
	then 	return 0
	else 	printf "err: YEAR must be in the format \`[-]YYYY' -- %s\n" "$1" >&2
	fi
	return 1
}

#verbose check if year is leap
function is_leapyear_verbose
{
	typeset year
	year="$1"
	if is_leapyear $year
	then 	((OPTVERBOSE)) || printf 'leap year -- %4s\n' $year
	else 	((OPTVERBOSE)) || printf 'not leap year -- %4s\n' $year
		false
	fi
}
#https://stackoverflow.com/questions/32196629/my-shell-script-for-checking-leap-year-is-showing-error

#Easter date in a given year
#usage: easterf [YEAR]
function easterf
{
	echo ${1:?year required} '[ddsf[lfp[too early
]Pq]s@1583>@
ddd19%1+sg100/1+d3*4/12-sx8*5+25/5-sz5*4/lx-10-sdlg11*20+lz+lx-30%
d[30+]s@0>@d[[1+]s@lg11<@]s@25=@d[1+]s@24=@se44le-d[30+]s@21>@dld+7%-7+
[March ]smd[31-[April ]sm]s@31<@psnlmPpsn1z>p]splpx' | dc
}
#Dershowitz' and Reingold' Calendrical Calculations book

#Carnaval and Corpus Christi in a given year
#usage: carnavalf [YEAR]
function carnavalf
{
	typeset year month day unix1 unixEaster unixCarnaval unixCorpus

	{ 	read day
		read month year
	} < <(easterf "$@")
	
	((${#day}==2)) || day=0$day
	month=$(monthconv $month)

	unixEaster=$(get_unixf $year-$month-$day)
	((unixCarnaval=unixEaster-(47*24*60*60) ))
	((unixCorpus=unixEaster+(60*24*60*60) ))
	
	if ((OPTRR))
	then
		printf '%.16s\t%.16s\t%.16s\n' \
			"$(unix_toiso -R $unixCarnaval)" \
			"$(unix_toiso -R $unixEaster)" \
			"$(unix_toiso -R $unixCorpus)"
	else 	printf '%.10s\t%.10s\t%.10s\n' \
			"$(unix_toiso $unixCarnaval)" \
			"$year-${month:0:3}-$day" \
			"$(unix_toiso $unixCorpus)"
	fi
}
#https://www.inf.ufrgs.br/~cabral/Pascoa.html
#https://www.inf.ufrgs.br/~cabral/tabela_pascoa.html
#http://ghiorzi.org/portug2.htm

#get the month number
function monthconv
{
	case "$1" in
		[Dd]ec*) 	echo 12;; [Nn]ov*) 	echo 11;;
		[Oo]ct*) 	echo 10;; [Ss]ep*) 	echo 09;;
		[Aa]ug*) 	echo 08;; [Jj]ul*) 	echo 07;;
		[Jj]un*) 	echo 06;; [Mm]ay*) 	echo 05;;
		[Aa]pr*) 	echo 04;; [Mm]ar*) 	echo 03;;
		[Ff]eb*) 	echo 02;; [Jj]an*) 	echo 01;;
		12) 	echo December;; 11) 	echo November;;
		10) 	echo October;;  *9) 	echo September;;
		*8) 	echo August;;   *7) 	echo July;;
		*6) 	echo June;;     *5) 	echo May;;
		*4) 	echo April;;    *3) 	echo March;;
		*2) 	echo February;; *1) 	echo January;;
	esac
}

#get the name of day in the week
#usage: get_day_in_week unix_time
function get_day_in_week
{
	typeset unix
	set -- "${1:-0}";
	((unix=10#${1##[+-]}));
	case "$1" in -*) 	unix=-$unix;; esac;
	echo ${DAY_OF_WEEK[( ( (unix+(unix<0?1:0))/(24*60*60))%7 +(unix<0?6:7))%7]}
}

#get the value of a day in the year
#usage: get_day_in_year year month day
function get_day_in_year
{
	typeset day month year month_test daysum
	set -- "${1:-1}" "${2:-1}" "${3:-0}";
	((day=  10#${1}));
	((month=10#${2}));
	((year= 10#${3##[+-]}));
	case "$3" in -*) 	year=-$year;; esac;

	for ((month_test=1;month_test<month;++month_test))
	do 	((daysum+=${YEAR_MONTH_DAYS[month_test-1]}))
	done
	((month>2)) && is_leapyear $year && ((daysum++))

	echo $((day+daysum))
}

#return phase of the moon, UTC time
#usage: phase_of_the_moon year [month] [day]
function phase_of_the_moon 		#0-7, with 0: new, 4: full
{
	typeset day month year diy goldn epact
	set -- "${1:-1}" "${2:-1}" "${3:-1970}";
	((day=  10#${1}));
	((month=10#${2}));
	((year= 10#${3##[+-]}));
	case "$3" in -*) 	year=-$year;; esac;
	((year+=CFACTOR))  #correction factor: -1892

	diy=$(get_day_in_year "$day" "$month" "$year")
	((goldn = (year % 19) + 1))
	((epact = (11 * goldn + 18) % 30))
	(((epact == 25 && goldn > 11) || epact == 24 )) && ((epact++))
	
	case $(( ( ( ( ( (diy + epact) * 6) + 11) % 177) / 22) & 7)) in
		0) 	set -- 'New Moon'        ;; # ~.0
		1) 	set -- 'Waxing Crescent' ;;
		2) 	set -- 'First Quarter'   ;; # ~.25
		3) 	set -- 'Waxing Gibbous'  ;;
		4) 	set -- 'Full Moon'       ;; # ~.5
		5) 	set -- 'Waning Gibbous'  ;;
		6) 	set -- 'Last Quarter'    ;; # ~.75
		7) 	set -- 'Waning Crescent' ;;
	esac
	#Bash's integer division truncates towards zero as in C
	case "$*" in "$PHASE_SKIP") 	return;; *) 	PHASE_SKIP="$*";; esac;
	if ((OPTVERBOSE))
	then 	printf '%s\n' "$*"
	else 	printf '%04d-%02d-%02d  %s\n' "$((year-CFACTOR))" "$month" "$day" "$*"
	fi
}
#<https://nethack.org/>
#<https://aa.usno.navy.mil/data/MoonPhases>
#<https://aa.usno.navy.mil/faq/moon_phases>
#<http://astropixels.com/ephemeris/phasescat/phases1901.html>
#<https://www.nora.ai/competition/fishai-dataset-competition/about-the-dataset/>
#<https://www.kaggle.com/datasets/lsind18/full-moon-calendar-1900-2050>
#<https://www.fullmoon.info/en/fullmoon-calendar_1900-2050.html>
#Correction Factor was calculated comparing with USNO Navy data.
#also see explanation in Dershowitz and Reingold's: 8.1 Orthodox Easter

#print (current) time
#usage: get_timef [unix_time] [print_format]
function get_timef
{
	typeset input fmt
	input=${1#@}  fmt="${2:-${TIME_ISO8601_FMT}}"
	if ((OPTDD))
	then 	echo $EPOCH ;false
	elif [[ -n $ZSH_VERSION ]]
	then 	zmodload -aF zsh/datetime b:strftime && strftime "$fmt" $input
	elif [[ -n $BASH_VERSION ]]
	then  	printf "%(${fmt})T\n" ${input:--1}
	else 	printf "%(${fmt})T\n" ${input:+$(unix_toiso $input)}
	fi
	#zsh and bash accept unix time input, ksh accepts iso8601
}

#generate unix time arithmetically
#usage: get_unixf iso-8601_date
function get_unixf
{
	GETUNIX=1 OPTVERBOSE=1 DATE_CMD=false OPTRR= TZ= mainf "$EPOCH" "$1"
}

#generate ISO8601 or RFC5322 from UNIX time
#usage: unix_toiso [-R] UNIX [+1|-1] [tzXh] [$tzXm] [tzXs] [+1|-1] [TZh] [$TZm] [TZs]
function unix_toiso
{
	typeset unix unix_adj y_test mo_test d_test max_mday max_yday daysum optr neg_tz tzh tzm tzs TZ_neg TZ_pos TZh TZm TZs noTZs
	[[ $1 = -R ]] && { 	optr=1 ;shift ;}
	
	((unix=10#0${1##[+-]}));
	case "$1" in -*) 	unix=-$unix;; esac;

	neg_tz=${2:--1} tzh=$3 tzm=$4 tzs=$5
	TZ_neg=${6:--1} TZh=$7 TZm=$8 TZs=$9
	
	TZ_pos=${TZ_neg/-/+} TZ_pos=${TZ_pos##$TZ_neg} TZ_pos=${TZ_pos:-${TZ_neg/+/-}}
	((unix+=( ( (tzh*60*60)+(tzm*60)+tzs)*neg_tz)-( ( (TZh*60*60)+(TZm*60)+TZs)*TZ_neg) ))
	unix_adj=$unix

	if ((unix<0))
	then 	y_test=1969 mo_test=12 d_test=31
		max_mday=31 max_yday=365
	
		while ((unix<-max_yday*24*60*60))
		do 	((daysum+=max_yday, unix+=max_yday*24*60*60))
			((--y_test))
			max_yday=$(year_days_adj 1 $y_test)
		done
		while ((unix<-max_mday*24*60*60))
		do 	((daysum+=max_mday, unix+=max_mday*24*60*60))
			((mo_test==1)) && ((--y_test))
			((mo_test==1)) && mo_test=12 || ((--mo_test))
			max_mday=$(month_maxday $mo_test $y_test)
		done
		((d_test=max_mday+( (unix+1)/(24*60*60) ) , daysum-=unix/(24*60*60) , unix%=24*60*60))
		((unix)) && ((h_test=23+( (unix+1)/(60*60) ) , unix%=60*60))
		((unix)) && ((m_test=59+( (unix+1)/60) , unix%=60))
		((unix)) && ((s_test=60+unix))
	else
		y_test=1970 mo_test=1 d_test=1
		max_mday=31 max_yday=365
	
		while ((unix>=max_yday*24*60*60))
		do 	((daysum+=max_yday, unix-=max_yday*24*60*60))
			((++y_test))
			max_yday=$(year_days_adj 1 $y_test)
		done
		while ((unix>=max_mday*24*60*60))
		do 	((mo_test==12)) && ((++y_test))
			((mo_test==12)) && mo_test=1 || ((++mo_test))
			((daysum+=max_mday, unix-=max_mday*24*60*60))
			max_mday=$(month_maxday $mo_test $y_test)
		done
		((d_test+=unix/(24*60*60) , daysum+=unix/(24*60*60) , unix%=24*60*60))
		((h_test=unix/(60*60) , unix%=60*60))
		((m_test=unix/60 , unix%=60))
		((s_test=unix))
	fi

	((TZs)) || noTZs='?????'
	if ((optr))
	then 	printf "${TIME_RFC5322_FMT_PF%$noTZs}\n" \
			"$(get_day_in_week $unix_adj)" \
			"${d_test}" "$(monthconv $mo_test)" "$y_test" \
			"$h_test" "$m_test" "$s_test" \
			"$TZ_pos" "$TZh" "$TZm" ${TZs#0}
	else
		printf "${TIME_ISO8601_FMT_PF%$noTZs}\n" \
			"$y_test" "$mo_test" "${d_test}" \
			"$h_test" "$m_test" "$s_test" \
			"$TZ_pos" "$TZh" "$TZm" ${TZs#0}
	fi
}

#get friday 13th dates
#usage: friday_13th [weekday_name] [day] [start_year]
function friday_13th
{
	typeset glob1 glob2 dow_name d_tgt diw_tgt day month year unix diw d_away maxday skip n
	dow_name=("${DAY_OF_WEEK[@]}") ;DAY_OF_WEEK=(0 1 2 3 4 5 6)
	glob1='[SsMmTtWwFf]*' glob2='?([0-3])[0-9]'

	#set day of week and day of month
	[[ $2 = $glob1 ]] && set -- "${@:2:1}" "${@:1:1}" "${@:3}"
	if [[ $1 = $glob1 ]]
	then 	case $1 in
			[Ss][Aa]*) 	diw_tgt=${DAY_OF_WEEK[2]};;
			[Ff]*) 	diw_tgt=${DAY_OF_WEEK[1]};;
			[Tt][Hh]*) 	diw_tgt=${DAY_OF_WEEK[0]};;
			[Ww]*) 	diw_tgt=${DAY_OF_WEEK[6]};;
			[Tt]*) 	diw_tgt=${DAY_OF_WEEK[5]};;
			[Mm]*) 	diw_tgt=${DAY_OF_WEEK[4]};;
			[Ss]*) 	diw_tgt=${DAY_OF_WEEK[3]};;
		esac ;shift
	fi ;diw_tgt=${diw_tgt:-1}

	[[ $1 = $glob2 ]] && { 	d_tgt=$1 && shift ;} || d_tgt=13
	IFS="$IFS$SEP" ;set -- $@ ;(($#)) || set -- $(IFS=$' \t\n' get_timef) ;IFS=$' \t\n'
	day="${3#0}"    month="${2#0}"      year="${1##*(0)}"
	day="${day:-1}" month="${month:-1}" year="${year:-0}"
	
	unix=$(datefun ${year}-${month}-${day} +%s) ||
		unix=$(get_unixf ${year}-${month}-${day}) || return $?

	while diw=$(get_day_in_week $((unix+(d_away*24*60*60) )) )
	do 	if ((diw==diw_tgt && day==d_tgt))
		then 	if ((!(d_away+OPTVERBOSE+OPTFF-1) ))
			then 	printf "${TIME_RFC5322_FMT_PF:0:20} is today!\n" \
				"${dow_name[diw_tgt]}" "$day" "${MONTH_OF_YEAR[month-1]}" "$year"
			elif ((OPTVERBOSE))
			then 	printf "${TIME_ISO8601_FMT_PF:0:14}\n" "$year" "$month" "$day"
			else 	printf "${TIME_RFC5322_FMT_PF:0:20} is %4d days away\n" \
				"${dow_name[diw_tgt]}" "$day" "${MONTH_OF_YEAR[month-1]}" "$year" "$d_away"
			fi
			((++n))
			((OPTFF==1||(OPTFF==2&&n>=10) )) && break
		fi
		if ((day<d_tgt))  #days away
		then 	((d_away=d_tgt-day, day=d_tgt, skip=1))
		elif 	maxday=$(month_maxday $month $year)
			((day>d_tgt))
		then 	((d_away=(maxday-day+d_tgt), day=d_tgt))
		else 	((d_away+=maxday))
		fi
		if ((!skip))
		then 	((month==12)) && ((++year))
			((month=(month==12?1:month+1) ))
		fi ;skip=
	done
}

#printing helper
#(A). check if floating point in $1 is `>0', set return signal and $SS to `s' when `>1.0'.
#usage: prHelpf 1.23
#(B). set padding of $1 length until [max] chars and set $SSS.
#usage: prHelpf 1.23  [max]
function prHelpf
{
	typeset val valx int dec  x z
	#(B)
	if (($# >1))
	then 	SSS=  x=$(( ${2} - ${#1} ))
		for ((z=0;z<x;++z))
		do 	SSS="$SSS "
		done
	fi

	#(A)
	SS=  val=${1#-} val=${val#0} valx=${val//[0.]} int=${val%.*}
	[[ $val = *.* ]] && dec=${val#*.} dec=${dec//0}
	[[ -n $1 && -n $OPTT ]] || ((valx)) || return
	(( int>1 || ( (int==1) && (dec) ) )) && SS=s
	return 0
}

#datediff fun
function mainf
{
	${DEBUG:+unset} \
	typeset date1_iso8601 date2_iso8601 unix1 unix2 inputA inputB range neg_range yearA monthA dayA hourA minA secA tzA neg_tzA tzAh tzAm tzAs yearB monthB dayB hourB minB secB tzB neg_tzB tzBh tzBm tzBs years_between y_test leapcount daycount_leap_years daycount_years fullmonth_days fullmonth_days_save monthcount month_test month_tgt d1_mmd d2_mmd date1_month_max_day date3_month_max_day date1_year_days_adj d_left y mo w d h m s bc bcy bcmo bcw bcd bch bcm range_pr sh d_left_save d_sum date1_iso8601_pr date2_iso8601_pr yearAtz monthAtz dayAtz hourAtz minAtz secAtz yearBtz monthBtz dayBtz hourBtz minBtz secBtz range_check now globtest varname buf var ok ar ret n p q r v TZh TZm TZs TZ_neg TZ_pos spcr  #SS SSS

	(($# == 1)) && set -- '' "$1"

	#warp `date' when available
	if 	unix1=$(datefun "${1:-+%s}" ${1:++%s}) &&
		unix2=$(datefun "${2:-+%s}" ${2:++%s})
	then 	#sort dates
		if ((unix1 > unix2))
		then 	buf=$unix2 unix2=$unix1 unix1=$buf neg_range=-1
			set -- "$2" "$1" "${@:3}"
		fi
		{
		date1_iso8601=$(datefun -Iseconds @"$unix1")
		date2_iso8601=$(datefun -Iseconds @"$unix2")
		if [[ -z $OPTVERBOSE && -n $OPTRR ]]
		then 	date1_iso8601_pr=$(datefun -R @"$unix1")
			date2_iso8601_pr=$(datefun -R @"$unix2")
		fi
		}  2>/dev/null  #avoid printing errs from FreeBSD<12 `date'
	else 	unset unix1 unix2
		#set default date -- AD
		[[ -z $1 || -z $2 ]] && now=$(get_timef)
		[[ -z $1 ]] && { 	set -- "${now}" "${@:2}"      ;date1_iso8601="$now" ;}
		[[ -z $2 ]] && { 	set -- "$1" "${now}" "${@:3}" ;date2_iso8601="$now" ;}
	fi

	#load ISO8601 dates from `date' or user input
	inputA="${date1_iso8601:-$1}"  inputB="${date2_iso8601:-$2}"
	if [[ -z $unix2 ]]  #time only input, no `date' pkg available
	then 	[[ $inputA = *([0-9]):* ]] && inputA="${EPOCH:0:10}T${inputA}"
		[[ $inputB = *([0-9]):* ]] && inputB="${EPOCH:0:10}T${inputB}"
	fi
	IFS="${IFS}${SEP}UuGgZz" read yearA monthA dayA hourA minA secA  tzA <<<"${inputA##*(+|-)}"
	IFS="${IFS}${SEP}UuGgZz" read yearB monthB dayB hourB minB secB  tzB <<<"${inputB##*(+|-)}"
	IFS="${IFS}${SEP/[Tt]}" read tzAh tzAm tzAs  var <<<"${tzA##?($GLOBUTC?(+|-)|[+-])}"
	IFS="${IFS}${SEP/[Tt]}" read tzBh tzBm tzBs  var <<<"${tzB##?($GLOBUTC?(+|-)|[+-])}"
	IFS="${IFS}${SEP/[Tt]}" read TZh TZm TZs  var <<<"${TZ##?($GLOBUTC?(+|-)|[+-])}"

	#fill in some defaults
	monthA=${monthA:-1} dayA=${dayA:-1}  monthB=${monthB:-1} dayB=${dayB:-1}
	#support offset as `[+-]XXXX??'
	globtest='[0-9][0-9][0-9][0-9]?([0-9][0-9])'
	[[ $tzAh = $globtest ]] && tzAs=${tzAh:4:2} tzAm=${tzAh:2:2} tzAh=${tzAh:0:2}
	[[ $tzBh = $globtest ]] && tzBs=${tzBh:4:2} tzBm=${tzBh:2:2} tzBh=${tzBh:0:2}
	[[ ${TZh} = $globtest ]] &&  TZs=${TZh:4:2}   TZm=${TZh:2:2}   TZh=${TZh:0:2}

	#set parameters as decimals ASAP
	for varname in yearA monthA dayA hourA minA secA  \
		yearB monthB dayB hourB minB secB  \
		tzAh tzAm tzAs  tzBh tzBm tzBs  TZh TZm TZs
	do 	eval "[[ \${$varname} = *[A-Za-z_]* ]] && continue"  #avoid printing errs
		eval "(($varname=10#0\${$varname##[+-]}))";
	done

	#negative years
	case "$inputA" in -?*) 	yearA=-$yearA;; esac;
	case "$inputB" in -?*) 	yearB=-$yearB;; esac;
	#
	#iso8601 date string offset
	[[ ${inputA%"${tzA##?($GLOBUTC?(+|-)|[+-])}"} = *?+ ]] && neg_tzA=+1 || neg_tzA=-1
	[[ ${inputB%"${tzB##?($GLOBUTC?(+|-)|[+-])}"} = *?+ ]] && neg_tzB=+1 || neg_tzB=-1
	((tzAh==0 && tzAm==0 && tzAs==0)) && neg_tzA=+1
	((tzBh==0 && tzBm==0 && tzBs==0)) && neg_tzB=+1
	#
	#environment $TZ
	[[ ${TZ##*$GLOBUTC} = +?* ]] && TZ_neg=+1 TZ_pos=-1 || TZ_neg=-1 TZ_pos=+1
	[[ $TZh$TZm$TZs = *([0-9+-]) && -z $unix2 ]] || unset TZh TZm TZs

	#24h clock and input leap second support (these $tz* parameters will be zeroed later)
	((hourA==24)) && (( (neg_tzA>0 ? (tzAh-=hourA-23) : (tzAh+=hourA-23) ) , (hourA-=hourA-23) ))
	((hourB==24)) && (( (neg_tzB>0 ? (tzBh-=hourB-23) : (tzBh+=hourB-23) ) , (hourB-=hourB-23) ))
	 ((minA==60)) && (( (neg_tzA>0 ?  (tzAm-=minA-59) :  (tzAm+=minA-59) ) ,   (minA-=minA-59) ))
	 ((minB==60)) && (( (neg_tzB>0 ?  (tzBm-=minB-59) :  (tzBm+=minB-59) ) ,   (minB-=minB-59) ))
	 ((secA==60)) && (( (neg_tzA>0 ?  (tzAs-=secA-59) :  (tzAs+=secA-59) ) ,   (secA-=secA-59) ))
	 ((secB==60)) && (( (neg_tzB>0 ?  (tzBs-=secB-59) :  (tzBs+=secB-59) ) ,   (secB-=secB-59) ))
	#CHECK SCRIPT `GLOBS', TOO, as they may fail with weyrd dates and formats.

	#check input validity
	d1_mmd=$(month_maxday "$monthA" "$yearA") ;d2_mmd=$(month_maxday "$monthB" "$yearB")
	if ! (( (yearA||yearA==0) && (yearB||yearB==0) && monthA && monthB && dayA && dayB )) ||
		((
			monthA>12 || monthB>12 || dayA>d1_mmd || dayB>d2_mmd
			|| hourA>23 || hourB>23 || minA>59 || minB>59 || secA>59 || secB>59
		))
	then 	echo "err: illegal user input -- ISO-8601 DATE required" >&2 ;return 2
	fi

	#offset and $TZ support
	if ((tzAh||tzAm||tzAs||tzBh||tzBm||tzBs||TZh||TZm||TZs))
	then 	#check validity
		if ((tzAh>24||tzBh>24||tzAm>60||tzBm>60||tzAs>60||tzBs>60))
		then 	echo "warning: illegal offsets" >&2
			unset tzA tzB  tzAh tzAm tzAs  tzBh tzBm tzBs
		fi
		if ((TZh>23||TZm>59||TZs>59))
		then 	echo "warning: illegal environment \$TZ" >&2
			unset TZh TZm TZs
		fi 	#offset specs:
		#<https://www.w3.org/TR/NOTE-datetime>
		#<https://www.gnu.org/software/libc/manual/html_node/TZ-Variable.html>

		#environment $TZ support  #only for printing
		if ((!OPTVERBOSE)) && ((TZh||TZm||TZs))
		then 	[[ -z $tzA ]] && ((tzAh-=(TZh*TZ_neg), tzAm-=(TZm*TZ_neg), tzAs-=(TZs*TZ_neg) ))
			[[ -z $tzB ]] && ((tzBh-=(TZh*TZ_neg), tzBm-=(TZm*TZ_neg), tzBs-=(TZs*TZ_neg) ))
		else 	unset TZh TZm TZs
		fi

		#convert dates to UTC for internal range calculations
		((tzAh||tzAm||tzAs)) && var="A" || var=""
		((tzBh||tzBm||tzBs)) && var="$var B"
		for v in $var  #A B
		do 	#secAtz secBtz
			((sec${v}tz+=sec${v}-(tz${v}s*neg_tz${v}) ))  #neg_tzA neg_tzB
			if ((sec${v}tz<0))
			then 	((min${v}tz+=((sec${v}tz-59)/60) , sec${v}tz=(sec${v}tz%60+60)%60))
			elif ((sec${v}tz>59))
			then 	((min${v}tz+=(sec${v}tz/60) , sec${v}tz%=60))
			fi

			#minAtz minBtz
			((min${v}tz+=min${v}-(tz${v}m*neg_tz${v}) ))
			if ((min${v}tz<0))
			then 	((hour${v}tz+=((min${v}tz-59)/60) , min${v}tz=(min${v}tz%60+60)%60))
			elif ((min${v}tz>59))
			then 	((hour${v}tz+=(min${v}tz/60) , min${v}tz%=60))
			fi
			
			#hourAtz hourBtz
			((hour${v}tz+=hour${v}-(tz${v}h*neg_tz${v}) ))
			if ((hour${v}tz<0))
			then	((day${v}tz+=((hour${v}tz-23)/24) , hour${v}tz=(hour${v}tz%24+24)%24))
			elif ((hour${v}tz>23))
			then 	((day${v}tz+=(hour${v}tz/24) , hour${v}tz%=24))
			fi

			#dayAtz dayBtz
			((day${v}tz+=day${v}))
			if ((day${v}tz<1))
			then 	var=$(month_maxday "$((month${v}==1 ? 12 : month${v}-1))" "$((year${v}))")
				((day${v}tz+=var))
				if ((month${v}>1))
				then 	((--month${v}tz))
				else 	((month${v}tz-=month${v}))
				fi
			elif var=$(month_maxday "$((month${v}))" "$((year${v}))")
				((day${v}tz>var))
			then 	((++month${v}tz))
				((day${v}tz%=var))
			fi
			
			#monthAtz monthBtz
			((month${v}tz+=month${v}))
			if ((month${v}tz<1))
			then 	((--year${v}tz))
				((month${v}tz+=12))
			elif ((month${v}tz>12))
			then 	((++year${v}tz))
				((month${v}tz%=12))
			fi

			((year${v}tz+=year${v}))  #yearAtz yearBtz
		done
		#modulus as (a%b + b)%b to avoid negative remainder.
		#<https://www.geeksforgeeks.org/modulus-on-negative-numbers/>

		if [[ -n $yearAtz ]]
		then 	(( 	yearA=yearAtz , monthA=monthAtz , dayA=dayAtz,
				hourA=hourAtz , minA=minAtz , secA=secAtz ,
				tzAh=0 , tzAm=0 , tzAs=0
			))
		fi
		if [[ -n $yearBtz ]]
		then 	(( 	yearB=yearBtz , monthB=monthBtz , dayB=dayBtz,
				hourB=hourBtz , minB=minBtz , secB=secBtz ,
				tzBh=0 , tzBm=0 , tzBs=0
			))
		fi
	elif [[ -z $unix2$OPTVERBOSE && $tzA$tzB$TZ = *+([A-Za-z_])* ]]
	then 	#echo "warning: input DATE or \$TZ contains timezone ID or name. Support requires package \`date'" >&2
		unset tzA tzB  tzAh tzBh tzAm  tzBm tzAs tzBs  TZh TZm TZs
	else 	unset tzA tzB  tzAh tzBh tzAm  tzBm tzAs tzBs  TZh TZm TZs
	fi  #Offset is *from* UTC, while $TZ is *to* UTC.


	#sort `UTC' dates (if no `date' package)
	if [[ -z $unix2 ]] && ((
		(yearA>yearB)
		|| ( (yearA==yearB) && (monthA>monthB) )
		|| ( (yearA==yearB) && (monthA==monthB) && (dayA>dayB) )
		|| ( (yearA==yearB) && (monthA==monthB) && (dayA==dayB) && (hourA>hourB) )
		|| ( (yearA==yearB) && (monthA==monthB) && (dayA==dayB) && (hourA==hourB) && (minA>minB) )
		|| ( (yearA==yearB) && (monthA==monthB) && (dayA==dayB) && (hourA==hourB) && (minA==minB) && (secA>secB) )
	))
	then 	neg_range=-1
		for varname in inputA yearA monthA dayA hourA minA secA \
			yearAtz monthAtz dayAtz hourAtz minAtz secAtz \
			tzA tzAh tzAm tzAs neg_tzA date1_iso8601 date1_iso8601_pr UNIX1
		do      #swap $varA/$varB or $var1/$var2 values
			[[ $varname = *A* ]] &&  p=A q=B  ||  p=1 q=2
			eval "buf=\"\$$varname\""
			eval "$varname=\"\$${varname/$p/$q}\" ${varname/$p/$q}=\"\$buf\""
		done
		unset varname p q
		set -- "$2" "$1" "${@:3}"
	fi


	##Count leap years and sum leap and non leap years days,
	for ((y_test=(yearA+1);y_test<yearB;++y_test))
	do
		#((y_test==0)) && continue  #ISO8601 counts year zero, proleptic gregorian/julian do not
		is_leapyear $y_test && ((++leapcount))
		((++years_between))
		((monthcount += 12))
	done
	##count days in non and leap years
	(( daycount_leap_years = (366 * leapcount) ))
	(( daycount_years = (365 * (years_between - leapcount) ) ))

	#date2 days so far this year (this month)
	#days in prior months `this' year
	((month_tgt = (yearA==yearB ? monthA : 0) ))
	for ((month_test=(monthB-1);month_test>month_tgt;--month_test))
	do
		if ((month_test==2)) && is_leapyear $yearB
		then 	(( fullmonth_days += 29 ))
		else 	(( fullmonth_days += ${YEAR_MONTH_DAYS[month_test-1]} ))
		fi
		((++monthcount))
	done

	#date1 days until end of `that' year
	#days in prior months `that' year
	((yearA==yearB)) ||
	for ((month_test=(monthA+1);month_test<13;++month_test))
	do
		if ((month_test==2)) && is_leapyear $yearA
		then 	(( fullmonth_days += 29 ))
		else 	(( fullmonth_days += ${YEAR_MONTH_DAYS[month_test-1]} ))
		fi
		((++monthcount))
	done
	((fullmonth_days_save = fullmonth_days))

	#some info about input dates and their context..
	date3_month_max_day=$(month_maxday "$((monthB==1 ? 12 : monthB-1))" "$yearB")
	date1_month_max_day=$(month_maxday "$monthA" "$yearA")
	date1_year_days_adj=$(year_days_adj "$monthA" "$yearA")


	#set years and months
	(( y = years_between ))
	(( mo = (  monthcount - ( (years_between) ? (years_between * 12) : 0)  ) ))

	#days left
	if ((yearA==yearB && monthA==monthB))
	then 	
		((d_left = (dayB - dayA) ))
		((d_left_save = d_left))
	elif ((dayA<dayB))
	then
		((++mo))
		((fullmonth_days += date1_month_max_day))
		((d_left = (dayB - dayA) ))
		((d_left_save = d_left))
	elif ((dayA>dayB))
	then 	#refinement rules (or hacks)
		((d_left = ( (date3_month_max_day>=dayA) ? (date3_month_max_day-dayA) : (date1_month_max_day-dayA) ) + dayB ))
		((d_left_save = (date1_month_max_day-dayA) + dayB ))
		if ((dayA>date3_month_max_day && date3_month_max_day<date1_month_max_day && dayB>1))
		then 
			((dayB>=dayA-date3_month_max_day)) &&  ##addon2 -- prevents negative days
			((d_left -= date1_month_max_day-date3_month_max_day))
			((d_left==0 && ( (24-hourA)+hourB<24 || ( (24-hourA)+hourB==24 && (60-minA)+minB<60 ) || ( (24-hourA)+hourB==24 && (60-minA)+minB==60 && (60-secA)+secB<60 ) ) && (++d_left) ))  ##addon3 -- prevents breaking down a full month
			if ((d_left < 0))
			then 	if ((w))
				then 	((--w , d_left+=7))
				elif ((mo))
				then 	((--mo , w=date3_month_max_day/7 , d_left+=date3_month_max_day%7))
				elif ((y))
				then  	((--y , mo+=11 , w=date3_month_max_day/7 , d_left+=date3_month_max_day%7))
				fi
			fi
		elif ((dayA>date3_month_max_day))  #dayB==1
		then
			((d_left = (date1_month_max_day - dayA + date3_month_max_day + dayB) ))
			((w = d_left/7 , d_left%=7))
			if ((mo))
			then 	((--mo))
			elif ((y))
			then  	((--y , mo+=11))
			fi
		fi
	else 	#`dayA' equals `dayB'
		((++mo))
		((fullmonth_days += date1_month_max_day))
		#((d_left_save = d_left))  #set to 0
	fi


	((h += (24-hourA)+hourB))
	if ((h && h<24))
	then 	if ((d_left))
		then 	((--d_left , ++ok))
		elif ((mo))
		then 	((--mo , d_left+=date3_month_max_day-1 , ++ok))
		elif ((y))
		then  	((--y , mo+=11 , d_left+=date3_month_max_day-1 , ++ok))
		fi
	fi
	((h %= 24))

	((m += (60-minA)+minB))
	if ((m && m<60))
	then 	if ((h))
		then 	((--h))
		elif ((d_left))
		then 	((--d_left , h+=23 , ++ok))
		elif ((mo))
		then 	((--mo , d_left+=date3_month_max_day-1 , h+=23 , ++ok))
		elif ((y))
		then  	((--y , mo+=11 , d_left+=date3_month_max_day-1 , h+=23 , ++ok))
		fi
	fi
	((m %= 60))
	
	((s = (60-secA)+secB))
	if ((s && s<60))
	then 	if ((m))
		then 	((--m))
		elif ((h))
		then 	((--h , m+=59))
		elif ((d_left))
		then  	((--d_left , h+=23 , m+=59 , ++ok))
		elif ((mo))
		then 	((--mo , d_left+=date3_month_max_day-1 , h+=23 , m+=59 , ++ok))
		elif ((y))
		then  	((--y , mo+=11 , d_left+=date3_month_max_day-1 , h+=23 , m+=59 , ++ok))
		fi
	fi
	((s %= 60))
	((ok && (--d_left_save) ))

	((m += s/60 , s %= 60))
	((h += m/60 , m %= 60))
	((d_left_save += h/24))
	((d_left += h/24 , h %= 24))
	((y += mo/12 , mo %= 12))
	((w += d_left/7))
	((d = d_left%7))


	#total sum of full days { range = unix2-unix1 }
	((d_sum = (  (d_left_save) + (fullmonth_days + daycount_years + daycount_leap_years)  ) ))
	((range = (d_sum * 3600 * 24) + (h * 3600) + (m * 60) + s))

	#generate unix times arithmetically?
	((GETUNIX)) && { 	echo ${neg_range%1}${range} ;unset GETUNIX ;return ${ret:-0} ;}
	if [[ -z $unix2 ]]
	then 	if ((
			(yearA>1970 ? yearA-1970 : 1970-yearA)
			> (yearB>1970 ? yearB-1970 : 1970-yearB)
		)) || [[ -n $UNIX2 ]]
		then 	var=${UNIX2:-$yearB-$monthB-${dayB}T$hourB:$minB:$secB}  varname=B #utc times
		else 	var=${UNIX1:-$yearA-$monthA-${dayA}T$hourA:$minA:$secA}  varname=A
		fi

		[[ $var != *[!0-9.-]* ]] ||
		var=$(get_unixf $var) || ((ret+=$?))

		if [[ $varname = B ]]
		then 	((unix2=var , unix1=unix2-range))
		else 	((unix1=var , unix2=unix1+range))
		fi

		if ((OPTRR))  #make RFC-5322 format string
		then 	if ! { 	date2_iso8601_pr=$(get_timef "$unix2" "$TIME_RFC5322_FMT") &&
				date1_iso8601_pr=$(get_timef "$unix1" "$TIME_RFC5322_FMT") ;}
			then 	
				date2_iso8601_pr=$(unix_toiso -R "$unix2" \
					"$neg_tzB" "$tzBh" "$tzBm" "$tzBs" \
					"$TZ_neg"  "$TZh"  "$TZm"  "$TZs"
				)
				date1_iso8601_pr=$(unix_toiso -R "$unix1" \
					"$neg_tzA" "$tzAh" "$tzAm" "$tzAs" \
					"$TZ_neg"  "$TZh"  "$TZm"  "$TZs"
				)
			fi
		fi
	fi

	#single unit time durations (when `bc' is available)
	if ((OPTT || OPTVERBOSE<2))
	then 	if bc=( $(bc <<<" /* round argument 'x' to 'd' digits */
			define r(x, d) {
				auto r, s
				if(0 > x) {
					return -r(-x, d)
				}
				r = x + 0.5*10^-d
				s = scale
				scale = d
				r = r*10/10
				scale = s  
				return r
			};
			scale = ($SCL + 1);
			r( (${years_between:-0} + ( (${range:-0} - ( (${daycount_years:-0} + ${daycount_leap_years:-0}) * 24 * 60 * 60) ) / (${date1_year_days_adj:-0} * 24 * 60 * 60) ) ) , $SCL); /**  YEARS  **/
			r( (${monthcount:-0} + ( (${range:-0} - (${fullmonth_days_save:-0} * 24 * 60 * 60) ) / (${date1_month_max_day:-0} * 24 * 60 * 60) ) ) , $SCL); /**  MONTHS **/
			r( (${range:-0} / ( 7 * 24 * 60 * 60)) , $SCL); /**  WEEKS  **/
			r( (${range:-0} / (24 * 60 * 60)) , $SCL);  /**  DAYS   **/
			r( (${range:-0} / (60 * 60)) , $SCL);   /**  HOURS  **/
			r( (${range:-0} / 60) , $SCL);     /** MINUTES **/")
			)
		then 	bcy=${bc[0]} bcmo=${bc[1]} bcw=${bc[2]} bcd=${bc[3]} bch=${bc[4]} bcm=${bc[5]} 
			#ARRAY:  0=YEARS  1=MONTHS  2=WEEKS  3=DAYS  4=HOURS  5=MINUTES
		else 	typeset -F $SCL bcy bcmo bcw bcd bch bcm
			bcy="${years_between:-0} + ( (${range:-0} - ( (${daycount_years:-0} + ${daycount_leap_years:-0}) * 24 * 60 * 60.) ) / (${date1_year_days_adj:-0} * 24 * 60 * 60.) )"  #YEARS
			bcmo="${monthcount:-0} + ( (${range:-0} - (${fullmonth_days_save:-0} * 24 * 60 * 60.) ) / (${date1_month_max_day:-0} * 24 * 60 * 60.) )"  #MONTHS
			bcw="${range:-0} / ( 7 * 24 * 60 * 60.)"  #WEEKS
			bcd="${range:-0} / (24 * 60 * 60.)"   #DAYS
			bch="${range:-0} / (60 * 60.)"    #HOURS
			bcm="${range:-0} / 60."      #MINUTES
		fi

		#choose layout of single units
		if ((OPTT || !OPTLAYOUT))
		then 	#layout one
			spcr=' | '  #spacer
			prHelpf ${OPTTy:+${bcy}} && range_pr="${bcy} year$SS"
			prHelpf ${OPTTmo:+${bcmo}} && range_pr="${range_pr}${range_pr:+$spcr}${bcmo} month$SS"
			prHelpf ${OPTTw:+${bcw}} && range_pr="${range_pr}${range_pr:+$spcr}${bcw} week$SS"
			prHelpf ${OPTTd:+${bcd}} && range_pr="${range_pr}${range_pr:+$spcr}${bcd} day$SS"
			prHelpf ${OPTTh:+${bch}} && range_pr="${range_pr}${range_pr:+$spcr}${bch} hour$SS"
			prHelpf ${OPTTm:+${bcm}} && range_pr="${range_pr}${range_pr:+$spcr}${bcm} min$SS"
			prHelpf $range  ;((!OPTT||OPTTs)) && range_pr="$range_pr${range_pr:+$spcr}$range sec$SS"
			((OPTT&&OPTV)) && range_pr="${range_pr%[$IFS]*}"  #remove unit name
		else 	#layout two
			((n = ${#range}+SCL+1)) #range in seconds is the longest string
			prHelpf ${bcy} $n && range_pr="${BOLD}Year$SS${NC}"$'\t'$SSS${bcy}
			prHelpf ${bcmo} $n && range_pr="$range_pr"$'\n'"${BOLD}Month$SS${NC}"$'\t'$SSS${bcmo}
			prHelpf ${bcw} $n && range_pr="$range_pr"$'\n'"${BOLD}Week$SS${NC}"$'\t'$SSS${bcw}
			prHelpf ${bcd} $n && range_pr="$range_pr"$'\n'"${BOLD}Day$SS${NC}"$'\t'$SSS${bcd}
			prHelpf ${bch} $n && range_pr="$range_pr"$'\n'"${BOLD}Hour$SS${NC}"$'\t'$SSS${bch}
			prHelpf ${bcm} $n && range_pr="$range_pr"$'\n'"${BOLD}Min$SS${NC}"$'\t'$SSS${bcm}
			prHelpf $range $((n - (SCL>0 ? (SCL+1) : 0) ))
			range_pr="$range_pr"$'\n'"${BOLD}Sec$SS${NC}"$'\t'$SSS$range
			range_pr="${range_pr##*([$IFS])}"
			#https://www.themathdoctors.org/should-we-put-zero-before-a-decimal-point/
			((OPTLAYOUT>1)) && { 	p= q=. ;for ((p=0;p<SCL;++p)) ;do q="${q}0" ;done
				range_pr="${range_pr// ./0.}" range_pr="${range_pr}${q}" ;}
		fi
		unset SS SSS
	fi

	#set printing array with shell results
	sh=("$y" "$mo" "$w" "$d"  "$h" "$m" "$s")
	((y<0||mo<0||w<0||d<0||h<0||m<0||s<0)) && ret=${ret:-1}  #negative unit error
	[[ $bcy$bcmo$bcw$bcd$bch$bcm$range = *-* ]] && ret=${ret:-1}
	
	# Debugging
	if ((DEBUG))
	then
		#!#
		unix1=$unix1 unix2=$unix2 tzA=$tzA tzB=$tzB TZs=$TZs \
		date1_iso8601_pr="$date1_iso8601_pr" date1_iso8601="$date1_iso8601" \
		date2_iso8601_pr="$date2_iso8601_pr" date2_iso8601="$date2_iso8601" \
		debugf "$@"  || [[ $DATE_CMD = false ]] || printf "${BOLD}Debug:${NC} \`C-code date' is set!\\n" >&2;
	fi
	
	#print results
	if ((!OPTVERBOSE))
	then 	if [[ -z $date1_iso8601_pr$date1_iso8601 ]] 
		then 	date1_iso8601=$(unix_toiso "$unix1" \
				"$neg_tzA" "$tzAh" "$tzAm" "$tzAs" \
				"$TZ_neg"  "$TZh"  "$TZm"  "$TZs")
		fi
		if [[ -z $date2_iso8601_pr$date2_iso8601 ]] 
		then 	date2_iso8601=$(unix_toiso "$unix2" \
				"$neg_tzB" "$tzBh" "$tzBm" "$tzBs" \
				"$TZ_neg"  "$TZh"  "$TZm"  "$TZs")
		fi

		printf '%s%s\n%s%s%s\n%s%s%s\n%s\n'  \
			"${BOLD}DATES${NC}" "${neg_range%1}"  \
			"${date1_iso8601_pr:-${date1_iso8601:-$inputA}}" ''${unix1:+$'\t'} "$unix1"  \
			"${date2_iso8601_pr:-${date2_iso8601:-$inputB}}" ''${unix2:+$'\t'} "$unix2"  \
			"${BOLD}RANGES${NC}"
	fi
	((OPTVERBOSE<1 || OPTVERBOSE>1)) && { 	((OPTVERBOSE>2)) && v= || v=' '  #AST `date -E' style
		printf "%dY${v}%02dM${v}%02dW${v}%02dD${v}${v}%02dh${v}%02dm${v}%02ds\n" "${sh[@]}"
	}
	((OPTVERBOSE<2)) && printf '%s\n' "${range_pr:-$range secs}"

	return ${ret:-0}
}

#Execute result checks against `datediff' and `date'.
function debugf { 	! : ;}


## Parse options
while getopts 01234567890DdeFf:hlmRr@tuv opt
do 	case $opt in
		[0-9]) 	SCL="$SCL$opt"
			;;
		d) 	((++DEBUG))
			;;
		D) 	DATE_CMD_DEBUG="${DATE_CMD_DEBUG:-${DATE_CMD:-date}}"  #save pkg date path
			[[ $DATE_CMD = false ]] && OPTDD=1  #-DD disables shell get_timef()
			DATE_CMD=false  #-D disables pkg 'date'
			;;
		e) 	((++OPTE)); OPTL=
			;;
		F) 	((++OPTFF))
			;;
		f) 	INPUT_FMT="$OPTARG" OPTF=1  #`BSD date' input format
			;;
		h) 	while read
			do 	[[ "$REPLY" = \#\ v* ]] || continue
				echo "$REPLY  ${KSH_VERSION:+ksh }$KSH_VERSION${ZSH_VERSION:+zsh }$ZSH_VERSION${BASH_VERSION:+bash }$BASH_VERSION"
				break
			done <"$0"
			echo "$HELP" ;exit
			;;
		l) 	OPTL=1  OPTE=
			;;
		m) 	OPTM=1
			;;
		R) 	OPTRR=1
			;;
		r|@) 	OPTR=1
			;;
		t) 	((++OPTLAYOUT))
			;;
		u) 	OPTU=1
			;;
		v) 	((++OPTVERBOSE, ++OPTV))
			;;
		\?) 	exit 1
			;;
	esac
done
shift $((OPTIND -1)); unset opt

#set proper environment!
SCL="${SCL:-1}"     #scale defaults
((OPTU)) && TZ=UTC  #set UTC time zone
export TZ

#test for BSD, GNU, AST or BUSYBOX date
if [[ $DATE_CMD = [Ff][Aa][Ll][Ss][Ee] ]]
then 	:
elif [[ $DATE_CMD = *@(busy|toy)box* ]]
then 	 DATE_CMD="${DATE_CMD% date} date" BUSYDATE=1
elif ! ${DATE_CMD:=date} --version
then 	if ${DATE_CMD%date}gdate --version
	then 	DATE_CMD=gdate
	elif ${DATE_CMD} -E
	then 	ASTDATE=1 	
	elif command -v ${DATE_CMD}
	then 	BSDDATE=1
	elif command -v busybox
	then 	DATE_CMD="busybox date" BUSYDATE=1
	else 	DATE_CMD=false
	fi
fi >/dev/null 2>&1

#stdin input (skip it for option -F)
[[ ${1//[$IFS]}$OPTFF = $GLOBOPT ]] && opt="$1" && shift
if ((!($# +OPTFF) )) && [[ ! -t 0 ]]
then
	globtest="*([$IFS])@($GLOBDATE?(+([$SEP])$GLOBTIME)|$GLOBTIME)*([$IFS])@($GLOBDATE?(+([$SEP])$GLOBTIME)|$GLOBTIME)?(+([$IFS])$GLOBOPT)*([$IFS])"  #glob for two ISO8601 dates and possibly pos arg option for single unit range
	while IFS= read -r || [[ -n $REPLY ]]
	do 	ar=($REPLY) ;((${#ar[@]})) || continue
		if ((!$#))
		then 	set -- "$REPLY" ;((OPTL)) && break
			#check if arg contains TWO ISO8601 dates and break
			if ((${#ar[@]}==3||${#ar[@]}==2)) && [[ \ $REPLY = @(*[$IFS]$GLOBOPT*|$globtest) ]]
			then 	set -- $REPLY  ;[[ $1 = $GLOBOPT ]] || break
			fi
		else 	if ((${#ar[@]}==2)) && [[ \ $REPLY = @(*[$IFS]$GLOBOPT|$globtest) ]]
			then 	set -- "$@" $REPLY
			else 	set -- "$@" "$REPLY"
			fi ;break
		fi
	done ;unset ar globtest REPLY
	[[ ${1//[$IFS]} = $GLOBOPT ]] && opt="$1" && shift
fi
[[ -n $opt ]] && set -- "$@" "$opt"

#set single time unit
opt="${opt:-${@: -1}}" opt="${opt//[$IFS]}"
if [[ $opt$OPTFF = $GLOBOPT ]]
then 	OPTT=1 OPTVERBOSE=1 OPTLAYOUT=
	case $opt in
		[yY]) 	OPTTy=1;;
		[mM][oO]) 	OPTTmo=1;;
		[wW]) 	OPTTw=1;;
		[dD]) 	OPTTd=1;;
		[hH]) 	OPTTh=1;;
		[mM]) 	OPTTm=1;;
		[sS]) 	OPTTs=1;;
	esac ;set -- "${@:1:$# -1}"  #zsh cannot take $#-1 with no space
else 	OPTTy=1 OPTTmo=1 OPTTw=1 OPTTd=1 OPTTh=1 OPTTm=1 OPTTs=1
fi ;unset opt
#caveat: `gnu date' understands `-d[a-z]', do `-d[a-z]0' to pass.

#whitespace trimming
if (($# >1))
then 	set -- "${1#"${1%%[!$IFS]*}"}" "${2#"${2%%[!$IFS]*}"}" "${@:3}"
	set -- "${1%"${1##*[!$IFS]}"}" "${2%"${2##*[!$IFS]}"}" "${@:3}"
elif (($#))
then 	set -- "${1#"${1%%[!$IFS]*}"}" ;set -- "${1%"${1##*[!$IFS]}"}"
fi

#-r, unix times
if ((OPTR && ${#1}+${#2})) || [[ \ $1\ $2 = *\ @[0-9.+-]* ]] 
then
	if [[ $DATE_CMD = false ]]
	then 	if ((${#1})) && [[ $1 != *[!0-9@.+-]* ]]
		then 	((UNIX1=10#${1##*[!0-9.]}));
			case "$1" in @-*|-*) 	UNIX1=-$UNIX1;; esac;
			set -- "$(unix_toiso "${UNIX1}")" "${@:2}";
		fi

		if ((${#2})) && [[ $2 != *[!0-9@.+-]* ]]
		then 	((UNIX2=10#${2##*[!0-9.]}));
			case "$2" in @-*|-*) 	UNIX2=-$UNIX2;; esac;
			set -- "$1" "$(unix_toiso "${UNIX2}")" "${@:3}";
		fi
	else
		#set dates for datefun() processing
		((${#2})) && [[ $2 != *[!0-9@.+-]* ]] &&
		  set -- "${@:1:1}" @"${2##@}" "${@:3}";
		((${#1})) && [[ $1 != *[!0-9@.+-]* ]] &&
		  set -- @"${1##@}" "${@:2}";
	fi
fi

#set defaults input for opts -leem
if ((OPTL+OPTE+OPTM))
then 	if [[ $1 != ${1:++([0-9])?([\ ${SEP}]?([01])[0-9]?([\ ${SEP}]?([0-3])[0-9]))} ]] #YYYY[-MM[-DD]]
	then 	var='+%Y' ;((OPTM)) && var='-I'
		var=$(TZ=UTC datefun "$1" $var) && set -- "$var" "${@:2}"
	elif [[ -z $1 ]]
	then 	var='%Y'  ;((OPTM)) && var='%Y-%m-%d'
		if var=$(TZ=UTC get_timef '' $var)
		then 	set -- $var
		else 	set -- ${EPOCH:0:$((OPTM?10:4))}
		fi
	fi ;unset var
fi

if ((OPTL))
then 	for YEAR
	do 	is_year "$YEAR" || continue
		if ! is_leapyear_verbose "$YEAR"
		then 	(($?>1)) && RET=2 ;RET="${RET:-$?}"
		fi
	done ;exit $RET
elif ((OPTE))
then 	((OPTE>1)) && ((!OPTVERBOSE)) && printf '%10s\t%10s\t%10s\n' Carnaval Easter CorpusChristi  #tsv header
	for YEAR
	do 	is_year "$YEAR" || continue
		if ((OPTE>1))
		then 	carnavalf "$YEAR"
		else 	DATE=$(easterf "$YEAR") ;echo $DATE
		fi
	done
elif ((OPTM))
then 	for DATE_Y  #fill in months and days
	do 	if [[ $DATE_Y = +([0-9]) ]]
		then 	set --
			for ((M=1;M<=12;++M)) ;do set -- "$@" "${DATE_Y}-$M" ;done
		else 	set -- "$DATE_Y" #;PHASE_SKIP=
		fi
		for DATE_M
		do 	if [[ $DATE_M = +([0-9])[\ $SEP]+([0-9]) ]]
			then 	set --
				DMAX=$(month_maxday "${DATE_M#*[\ $SEP]}" "${DATE_M%[\ $SEP]*}")
				for ((D=1;D<=DMAX;++D)) ;do set -- "$@" "${DATE_M}-$D" ;done
			else 	set -- "$DATE_M" #;PHASE_SKIP=
			fi
			for DATE
			do 	set -- ${DATE//[$SEP]/ }  # ISO8601 input
				phase_of_the_moon "$3" "$2" "$1"
			done
		done
	done
elif ((OPTFF))
then 	friday_13th "$@"
else
	 
	((DEBUG)) && . datediff.debug.sh || DEBUG= ;
	[[ -t 1 ]] && BOLD=$'\u001b[0;1m' NC=$'\u001b[m' || BOLD= NC= ;

	mainf "$@"
fi
