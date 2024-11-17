#!/usr/bin/env bash
# Convert amongst temperature units
# v0.6  sep/2024  by mountaineerbr

#defaults

#scale
SCALEDEF=2

#script name
SN="${0##*/}"

#make sure locale is set correctly
export LC_NUMERIC=C

#help
HELP="$SN - Convert amongst temperature units


SYNOPSIS
	$SN [-NUM] [-qr] TEMP [c|f|k] [c|f|k]
	$SN [-NUM] [-qr] TEMP [celsius|farenheit|kelvin] [celsius|farenheit|kelvin]


	The default function is to convert amongst absolute temperatures.
	For example, if it is 45 degrees Fahrenheit outside, it is 7.2
	degrees Celsius. TEMP is a floating point number and can be a
	simple arithmetic expression.

	If no unit is given, toggling between Celsius and Fahrenheit
	units will be activated for absolute temperature conversions.
	Toggling creates a temporary file at /tmp or equivalent. Input
	from stdin is supported.

	Option -r deals with relative temperatures conversions; for
	example, a change of 45 degrees Fahrenheit corresponds to a
	change of 25 degrees Celsius. 

	Option -NUM sets scale, NUM must be an integer; defaults=$SCALEDEF.
	Floating point results are rounded to scale and trailing zeroes
	are trimmed.

	Temperature unit conversions are nonlinear; for example, temper-
	ature conversions between Fahrenheit and Celsius scales cannot
	be done by simply multiplying by conversion factors. These equa-
	tions can only be used to convert from one specific temperature
	to another specific temperature; for example, you can show that
	the specific temperature of 0.0 Celsius equals 32 Fahrenheit, or
	that the specific temperature of 100 Celsius equals 212 Fahrenheit.
	However, a temperature difference of 100 degrees in the Celsius
	scale is the same as a temperature difference of 180 degrees in
	the Fahrenheit scale.


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
		45K =   25 C
		25C =   45 K
		25C =   25 K


SEE ALSO
	Please check Adrian Mariano's package \`units' and read manual
	section \`Temperature Conversions':
	<https://www.freebsd.org/cgi/man.cgi?query=units&sektion=1>

	Doctor FWG's post on temperature differences:
	<https://web.archive.org/web/20180705003041/http://mathforum.org/library/drmath/view/58418.html>
	
	Multiplications should be before divisions to avoid losing
	precision if scale is small:
	https://www.linuxquestions.org/questions/ubuntu-63/shell-script-to-convert-celsius-to-fahrenheit-929261/


WARRANTY
	This programme is licensed under GNU GPLv3 and above. It is
	distributed without support or bug corrections.

	Tested with GNU Bash 5.0.

	If useful, please consider sending feedback!  =)


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


#don't convert
isSameUnitf()
{
	local degsign
	if [[ "${FROMT:-x}${HELPER+x}" = "$TOT" ]]
	then 	[[ $TOT = [kK] ]] || degsign=º
		printf '%s%s%s\n' "$*" "${HELPER-$'\t'$degsign}" "${HELPER-$TOT}"
		return 2
	fi
	return 0
}

#calculator command
calcf()
{
	bc <<-!
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
	/* Serge3leo - https://stackoverflow.com/questions/26861118/rounding-numbers-with-bc-in-bash
	 * MetroEast - https://askubuntu.com/questions/179898/how-to-round-decimals-using-bc-in-bash
	 */
	/* Truncate trailing zeroes */
	define trunc(x){auto os;os=scale;for(scale=0;scale<=os;scale++)if(x==x/1){x/=1;scale=os;return x}}
	/* http://phodd.net/gnu-bc/bcfaq.html
	 */
	scale=$SCALE+1; trunc( round($* , $SCALE) )
	!
}

#convert amongst absolute temps
absolutef()
{
	local tot degsign res
	typeset -u tot

	#from fahrenheit
	if [[ "$FROMT" = f ]] || [[ -z "$FROMT" && "$*" != "$TOGGLET" ]]
	then 	[[ -z "$FROMT" ]] && TOGGLET="$*"
		#to celsius
		if [[ -z "${TOT/c}" ]]
		then 	tot=c res=$( calcf "( (${1}) - 32) * 5/9" )
		#to kelvin
		else 	tot=k res=$( calcf "( ( (${1}) - 32) * 5/9) + 273.15" )
		fi
	#from celsius
	elif [[ "$FROMT" = c ]]  || [[ -z "$FROMT" && "$*" = "$TOGGLET" ]]
	then 	[[ -z "$FROMT" ]] && TOGGLET=
		#to fahrenheit
		if [[ -z "${TOT/f}" ]]
		then 	tot=f res=$( calcf "( (${1}) * 9/5) + 32" )
		#to kelvin
		else 	tot=k res=$( calcf "(${1}) + 273.15/1" )
		fi
	#from kelvin
	else 	if [[ -z "${TOT/c}" ]]
		then 	tot=c res=$( calcf "(${1}) - 273.15/1" )
		#to fahrenheit
		else 	tot=f res=$( calcf "( ( (${1}) - 273.15) * 9/5) + 32" )
		fi
	fi

	[[ $tot = [kK] ]] || degsign=º
	printf '%s%s%s\n' "$res" "${HELPER-$'\t'$degsign}" "${HELPER-$tot}"
}

#convert amongst relative temps
relativef()
{
	local degsign kzero kvar kdelta tzero tvar tdelta

	#from farenheit or kelvin
	if [[ "$FROMT$TOT" = [fk] ]] || [[ -z "$FROMT" && "$*" != "$TOGGLET" ]]
	then 	[[ -z "$FROMT" ]] && FROMT=f TOGGLET="$*" 
		TOT=c
	#from celsius
	elif [[ "$FROMT$TOT" = c ]] || [[ -z "$FROMT" && "$*" = "$TOGGLET" ]]
	then 	[[ -z "$FROMT" ]] && FROMT=c TOGGLET=
		TOT=f
	fi
	
	#normalise temp unit for comparison in kelvin
	kzero=$( HELPER= TOGGLET= TOT=k absolutef 0)
	kvar=$(  HELPER= TOGGLET= TOT=k absolutef "$1")
	kdelta=$(calcf "$kvar - ( $kzero )" )

	#transform kelvin delta in target temp delta
	tzero=$( HELPER= TOGGLET= FROMT=k absolutef 0 )
	tvar=$(  HELPER= TOGGLET= FROMT=k absolutef "$kdelta" )
	tdelta=$(calcf "$tvar - ( $tzero )" )

	[[ $TOT = [kK] ]] || degsign=º
	printf '%s%s%s\n' "$tdelta" "${HELPER-$'\t'$degsign}" "${HELPER-$TOT}"
}


unset HELPER
#parse opts
while getopts 1234567890hHrRq c
do 	case $c in
		[0-9])  #scale
			SCALE="${c%%[.,]*}"
			;;
		[hH])
			#help
			echo "$HELP"
			exit 
			;;
		[qQ]) 	#quiet
			HELPER=
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

typeset -l UNITS
UNITS="$*" UNITS="${UNITS//[^a-z]}" UNITS="${UNITS//celsius/c}"
UNITS="${UNITS//farenheit/f}" UNITS="${UNITS//kelvin/k}"
if ILLEGAL='abdeg-jl-z' ;[[ "$UNITS" = *[$ILLEGAL]* ]]
then 	printf '%s: err: illegal unit -- %s\n' "$SN" "${UNITS//[^${ILLEGAL}]}" >&2
	exit 2
fi

set -- "${@//[^0-9,.-]}"  #remove units
set -- "${@/,/.}"  #change comma to dot

#from-unit is always the first
(( ${#UNITS} )) && FROMT="${UNITS:0:1}"

#to-unit is always the last
(( ${#UNITS} > 1 )) && TOT="${UNITS:${#UNITS}-1:1}"

[[ -n "$SCALE" ]] || SCALE="$SCALEDEF"

#toggle
TOGGLETTEMP="${TMPDIR:-/tmp}/$SN.$USER.togglet"
[[ -z "$FROMT" && -e "$TOGGLETTEMP" ]] && read TOGGLET <"$TOGGLETTEMP"

#conversion type
isSameUnitf "$*" || exit
if [[ -n "$OPTR" ]]
then 	relativef "$@"
else 	absolutef "$@"
fi
code=$?

#set toggle temp file?
if [[ -n "$TOGGLET" ]]
then 	if ! echo "$TOGGLET" >"$TOGGLETTEMP"
	then 	printf '%s: err: cannot create tmp file -- %s\n' "$SN" "$TOGGLETTEMP" >&2
		exit 1
	fi
elif [[ -e "$TOGGLETTEMP" ]]
then 	rm -- "$TOGGLETTEMP" || exit
fi

exit ${code:-0}
