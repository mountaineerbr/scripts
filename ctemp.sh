#!/usr/bin/env bash
# Convert amongst temperature units
# v0.7  dec/2024  by mountaineerbr

#defaults

#scale
SCALEDEF=2

#script name
SN="${0##*/}"

#help
HELP="$SN - Convert amongst temperature units


SYNOPSIS
	$SN [-NUM] [-qr] TEMP [c|f|k] [c|f|k]
	$SN [-NUM] [-qr] TEMP [celsius|farenheit|kelvin] [celsius|farenheit|kelvin]


	The default function is to convert amongst absolute temperatures.
	For example, if it is 45 degrees Fahrenheit outside, it is 7.2
	degrees Celsius. TEMP is a floating point number and can be a
	simple arithmetic expression.

	Option -r deals with relative temperatures conversions; for
	example, a change of 45 degrees Fahrenheit corresponds to a
	change of 25 degrees Celsius. 

	Option -NUM sets scale, NUM must be an integer; defaults=$SCALEDEF.
	Floating point results are rounded to scale and trailing zeroes
	are trimmed.

	Input from stdin is supported.


FORMULAS
	Formulas for absolute temperature convertions.
		 Tc = (5/9)*(Tf-32)
		 Tf = (9/5)*Tc+32
		 Tk = Tc+273.15

	Equivalence of absolute temperatures.
		37C =   98.60 F
		98F =   36.63 C
		 0K = -273.15 C

	Equivalence of relative temperature differences.
		45F =   25 C
		25K =   45 F
		25C =   25 K


SEE ALSO
	Please check Adrian Mariano's package \`units' and read manual
	section \`Temperature Conversions':
	<https://www.freebsd.org/cgi/man.cgi?query=units&sektion=1>

	Doctor FWG's post on temperature differences:
	<https://web.archive.org/web/20180705003041/http://mathforum.org/library/drmath/view/58418.html>
	
	Multiplications should be before divisions to avoid losing
	precision if scale is small:
	<https://www.linuxquestions.org/questions/ubuntu-63/shell-script-to-convert-celsius-to-fahrenheit-929261>


WARRANTY
	This programme is licensed under GNU GPLv3 and above. It is
	distributed without support or bug corrections.

	Tested with GNU Bash 5.0.


USAGE EXAMPLES
	$ $SN 10
	$ $SN 10 c
	$ $SN 10 f k
	$ $SN -4 10cf
	$ $SN -r -- 10cf
	$ $SN -- -273.15 C K
	$ echo 20 | $SN c


OPTIONS
	-NUM	Set scale; defaults=$SCALEDEF.
	-q 	Don't print unit in result.
	-r 	Convert relative temperatures."


#bc fun
calcf()
{
	bc <<!
/* Round argument 'x' to 'd' digits */
define round(x, d) {
  auto r, s
  if(0 > x) {
    return -round(-x, d)
  }
  r = x + 0.5*10^-d
  s = scale
  scale = d
  r = r*10/10
  scale = s  
  return r
};

/* Truncate trailing zeroes */
define trunc(x){auto os;os=scale;for(scale=0;scale<=os;scale++)if(x==x/1){x/=1;scale=os;return x}}

scale=${SCALE:-2}+1
trunc( round(${*} , ${SCALE:-2}) )
!
}
#Serge3leo - https://stackoverflow.com/questions/26861118
#MetroEast - https://askubuntu.com/questions/179898
#http://phodd.net/gnu-bc/bcfaq.html

#convert amongst absolute temps
absolutef()
{
	typeset tot degsign res
	typeset -u tot

	case "${FROMT}" in
	    #from fahrenheit
	    f|'')  if [[ -n "${TOT}" && -z "${TOT%%f}" ]]
		then 	tot=f res=$1
		#to celsius
		elif [[ -z "${TOT%%c}" ]]
		then 	tot=c res=$( calcf "( (${1}) - 32) * 5/9" )
		#to kelvin
		else 	tot=k res=$( calcf "( ( (${1}) - 32) * 5/9) + 273.15" )
		fi;;
	    #from celsius
	    c)  if [[ -n "${TOT}" && -z "${TOT%%c}" ]]
		then 	tot=c res=$1
		#to fahrenheit
		elif [[ -z "${TOT%%f}" ]]
		then 	tot=f res=$( calcf "( (${1}) * 9/5) + 32" )
		#to kelvin
		else 	tot=k res=$( calcf "(${1}) + 273.15/1" )
		fi;;
	    #from kelvin
	    k|*)  if [[ -n "${TOT}" && -z "${TOT%%k}" ]]
		then 	tot=k res=$1
		#to celsius
		elif [[ -z "${TOT%%c}" ]]
		then 	tot=c res=$( calcf "(${1}) - 273.15/1" )
		#to fahrenheit
		else 	tot=f res=$( calcf "( ( (${1}) - 273.15) * 9/5) + 32" )
		fi;;
	esac

	[[ $tot = [kK] ]] || degsign=º
	((QUIET)) && printf '%s\n' "$res" ||
	printf '%s %s%s\n' "$res" "$degsign" "$tot"
}

#convert amongst relative temps
relativef()
{
	typeset degsign kzero kvar kdelta tzero tvar tdelta

	case "${FROMT}${TOT}" in
	  #from farenheit or null
	  f|'')  [[ -z "$FROMT" ]] && FROMT=f
		TOT=c;;
	  #from celsius or kelvin
	  c|k|*) [[ -z "$FROMT" ]] && FROMT=c
		TOT=f;;
	esac
	
	#normalise temp unit for comparison in kelvin
	kzero=$(QUIET=1 TOT=k absolutef 0)
	kvar=$(QUIET=1 TOT=k absolutef "$1")
	kdelta=$(calcf "$kvar - ( $kzero )" )

	#transform kelvin delta in target temp delta
	tzero=$(QUIET=1 FROMT=k absolutef 0 )
	tvar=$(QUIET=1 FROMT=k absolutef "$kdelta" )
	tdelta=$(calcf "$tvar - ( $tzero )" )

	[[ $TOT = [kK] ]] || degsign=º
	((QUIET)) && printf '%s\n' "$tdelta" ||
	printf '%s %s%s\n' "$tdelta" "$degsign" "$TOT"
}
#  Temperature unit conversions are nonlinear; for example, temper-
#  ature conversions between Fahrenheit and Celsius scales cannot
#  be done by simply multiplying by conversion factors. These equa-
#  tions can only be used to convert from one specific temperature
#  to another specific temperature; for example, you can show that
#  the specific temperature of 0.0 Celsius equals 32 Fahrenheit, or
#  that the specific temperature of 100 Celsius equals 212 Fahrenheit.
#  However, a temperature difference of 100 degrees in the Celsius
#  scale is the same as a temperature difference of 180 degrees in
#  the Fahrenheit scale.


#prepare environment
export LC_NUMERIC=C

#parse opts
while getopts 1234567890hHrRqv c
do 	case $c in
		[0-9])  #scale
			SCALE="${SCALE}${c%%[.,]*}"
			;;
		[hH])
			#help
			echo "$HELP"
			exit 
			;;
		[qv]) 	#quiet
			QUIET=1
			;;
		[rR]) #relative temps
			OPTR=relative
			;;
		?) 	exit 1
			;;
	esac
done
shift $(( OPTIND - 1 ))
unset c

#insufficient arguments?
if ((${#@}==0)) && [[ -t 0 ]]
then 	echo "$HELP" >&2
	exit 1
elif [[ "$*" != *[0-9]* && ! -t 0 ]]
then	set -- $(</dev/stdin) "$@"
fi

typeset -l UNITS; UNITS="$*";
UNITS="${UNITS//[^a-z]}" UNITS="${UNITS//celsius/c}"
UNITS="${UNITS//farenheit/f}" UNITS="${UNITS//kelvin/k}"
if [[ "$UNITS" = *[abdeg-jl-z]* ]]
then 	printf '%s: err: illegal unit -- %s\n' "$SN" "${UNITS//[^abdeg-jl-z]}" >&2
	exit 2
fi

#from-unit is always the first
(( ${#UNITS} )) && FROMT="${UNITS:0:1}"

#to-unit is always the last
(( ${#UNITS} > 1 )) && TOT="${UNITS:${#UNITS}-1:1}"

[[ -n "$SCALE" ]] || SCALE="$SCALEDEF"

set -- "${@//[^0-9,.-]}"  #remove units
set -- "${@/,/.}"  #change comma to dot

#conversion type
if [[ -n "$OPTR" ]]
then 	relativef "$@"
else 	absolutef "$@"
fi
