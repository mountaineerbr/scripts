#!/usr/bin/env bash
# v0.4  nov/2024  by mountaineerbr  GPLv3+
# Convert geocoordinates to various formats

SCALE=${SCALE:-6}
SCALE_SEC=${SCALE_SEC:-1}

HELP="Name
	${0##*/} -- Geodesic Coordinate Converter


Synopsis
	${0##*/} [LATITUDE] [LONGITUDE]


Description
	Convert sexagesimal geocoordinates to decimal and vice-versa.

	Formats: degree minute second, degree decimal minute, and
	decimal degree.

	Input coordinates must both have the same format. Full stops
	are used for input and output decimal representation.


Environment
	SCALE        Set precision of decimal degrees and decimal minutes.
	             Defaults=$SCALE.

	SCALE_SEC    Set precision of decimal seconds. Defaults=$SCALE_SEC.


Examples
	${0##*/} +59.9139°  -10.7522°                    #Oslo
	${0##*/} 37°31.956000'N, 127°01.476720'E         #Seoul
	${0##*/} 33°52'11.44\" South, 151°12'29.83\" East  #Sydney
	${0##*/} 51 30 35.5140 N  0 7 5.1312 W           #London
	echo -22.90680 -43.17290 | ${0##*/}              #Rio de Janeiro
"
#GeoConvert from the C++ library geographiclib.
#https://www.e-education.psu.edu/natureofgeoinfo/c2_p12.html
#https://www.avenza.com/help/geographic-imager/5.0/coordinate_formats.htm
#https://en.wikipedia.org/wiki/Geographic_coordinate_conversion
#https://en.wikipedia.org/wiki/ISO_6709
#https://web.archive.org/web/20111009145601/http://www.xyz.au.com/members/intelligence/pdf_files/ISO_FDIS_6709.pdf

BCFUN=" /* round argument 'x' to 'd' digits */
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
 /* take integer part (modified) */
define int(d,x) {
    auto os,ret;os=scale
    scale=x;ret=d/1
    scale=os;return ret
};
scale=($SCALE+1);"

#decimal degrees to sex
dd_degf()
{
	bc <<<"${BCFUN}
		decdeg=${1:-0}
		deg=int(decdeg,0)
		
		decmin=(decdeg-int(decdeg,0))*60
		min=int(decmin,0)
		
		decsec=(decmin-int(decmin,0))*60
		sec=int(decsec,$SCALE)

		sec=r(sec,$SCALE_SEC)
		if(sec>=60){min+=1; sec%=60}
		if(min>=60){deg+=1; min%=60}

		deg;min;sec"
}

#degrees decimal minutes to sex
ddm_degf()
{
	bc <<<"${BCFUN}
		deg=${1:-0}
		decmin=${2:-0}
		min=int(decmin,0)
		
		decsec=(decmin-int(decmin,0))*60
		sec=int(decsec,$SCALE)

		sec=r(sec,$SCALE_SEC)
		if(sec>=60){min+=1; sec%=60}
		if(min>=60){deg+=1; min%=60}

		deg;min;sec"
}

geoconvf()
{
	local arg sign Ah Ahh Ax Ay Az Bh Bhh Bx By Bz dd ddm ddfmt ddmfmt

	set -- ${@//[!0-9a-zA-Z.+-]/ }
	for arg
	do 	unset sign  #coordenate sign eater
		case "$arg" in
			-|[Ss]|[Ss]outh|[WwOo]|[Ww]est|[SsWwOo-][0-9.]*|*[0-9.][SsWwOo])
				sign=-;;
			+|[Nn]|[Nn]orth|[EeLl]|[Ee]ast|[NnEeLl+][0-9.]*|*[0-9.][NnEeLl]|*)
				sign=+;;
		esac
		if [[ -n $sign ]]
		then 	if [[ -z $Ah$Bx ]]
			then 	Ah=$sign
			elif [[ -z $Bh ]]
			then 	Bh=$sign
			else 	printf 'err: input -- %s\a\n' "$arg" >&2
				exit 2
			fi
			if ((${#arg}>1))
			then 	case "$arg" in
					[Nn]orth|[Ee]ast|[Ss]outh|[Ww]est)
					  continue;;
					[0-9]*)
					  arg=${arg%%[Nn]orth]} arg=${arg%%[Ss]outh]}
					  arg=${arg%%[Ee]ast]}  arg=${arg%%[Ww]est]}
					  arg=${arg%%[NnSsEeWwLlOo+-]};;
					*)
					  arg=${arg##[Nn]orth]} arg=${arg##[Ss]outh]}
					  arg=${arg##[Ee]ast]}  arg=${arg##[Ww]est]}
					  arg=${arg##[NnSsEeWwLlOo+-]};;
				esac
			else 	continue
			fi
		fi

		if [[ -z $Ax ]]    #decimal degrees
		then 	Ax=$arg
			[[ $Ax = *[.]* ]] && Ay=' ' Az=' ' By=' ' Bz=' ' dd=1
		elif [[ -z $Ay ]]  #degrees decimal minutes
		then 	Ay=$arg
			[[ $Ay = *[.]* ]] && Az=' ' Bz=' ' ddm=1
		elif [[ -z $Az ]]
		then 	Az=$arg
		elif [[ -z $Bx ]]
		then 	Bx=$arg
		elif [[ -z $By ]]
		then 	By=$arg
		elif [[ -z $Bz ]]
		then 	Bz=$arg
		fi
	done

	#cardinal direction for print
	Ah=${Ah:-+} Bh=${Bh:-+}
	case "$Ah" in
		-) 	Ahh=S;;
		+|*) 	Ahh=N;;
	esac
	case "$Bh" in
		-) 	Bhh=W;;
		+|*) 	Bhh=E;;
	esac
	
	#standartise input to sexagesimal format
	set -- "$Ax" "$Ay" "$Az"  "$Bx" "$By" "$Bz";
	if ((dd+ddm))
	then  #from decimal degree fmt
		if ((dd))
		then 	set -- $( ((SCALE+=8, SCALE_SEC+=6));
			         dd_degf "$Ax"; dd_degf "$Bx");
		#from degree decimal minute fmt
		elif ((ddm))
		then 	set -- $( ((SCALE+=8, SCALE_SEC+=6));
			         ddm_degf "$Ax" "$Ay"; ddm_degf "$Bx" "$By");
		fi
	fi

	#convert to other fmts
	ddfmt=($(bc <<<"scale=($SCALE+1);
		${1} + (${2}/60) + (${3}/3600);
		${4} + (${5}/60) + (${6}/3600);"))
	ddmfmt=($(bc <<<"scale=($SCALE+1);
		${1}; (${2}+(${3}/60))/1;
		${4}; (${5}+(${6}/60))/1;"))

	# Print Formats
	# Decimal degrees
	printf "%s%0$((SCALE?SCALE+3:2)).${SCALE}f %s%0$((SCALE?SCALE+3:2)).${SCALE}f\n" "${Ah%%+}" ${ddfmt[0]}  "${Bh%%+}" ${ddfmt[1]}
	# Degrees, and decimal minutes
	printf "%02d°%0$((SCALE?SCALE+3:2)).${SCALE}f'%s %02d°%0$((SCALE?SCALE+3:2)).${SCALE}f'%s\n" ${ddmfmt[@]:0:2} $Ahh  ${ddmfmt[@]:2} $Bhh
	# Degrees, minutes, and decimal seconds
	printf "%02d°%02d'%0$((SCALE_SEC?SCALE_SEC+3:2)).${SCALE_SEC}f\"%s %02d°%02d'%0$((SCALE_SEC?SCALE_SEC+3:2)).${SCALE_SEC}f\"%s\n" ${@:1:3} $Ahh ${@:4} $Bhh &&
	((${#}==6))
}


if ((!$#)) && [[ ! -t 0 ]]
then 	set -f; set -- $(cat);
	set +f
fi

if [[ $* != *[0-9]* || $1 = -h || $1 = --help ]]
then 	printf '%s\n' "$HELP"
	exit 2
fi

geoconvf "$@"

