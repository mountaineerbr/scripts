#!/usr/bin/env bash
# wf.sh  --  weather forecast from the norway meteorological institute
# v0.6  dec/2024  by mountaineerbr

# Favourite Locations (globs)
# name:latitude:longitude:altitude;
WFAV="${WFAV}
bei[gj]ing:21.79416:112.0236:44
berlin:52.5170365:13.3888599:34
bras[íi]lia:-15.7934036:-47.8823172:1172
cape town:-33.918861:18.423300:31
curitiba:-25.4295963:-49.2712724:935
dubai:25.276987:55.296249:5
florian[óo]polis:-27.5973002:-48.5496098:3
honolulu:21.30694:-157.85833:5
la paz:-16.499998:-68.1333328:3625
lisbo[na]:38.736946:-9.142685:2
london:51.5073359:-0.12765:11
londrina:-23.3112878:-51.1595023:610
madrid:40.4165:-3.70256:657
manila:14.599512:120.984222:16
maring[áa]:-23.425269:-51.9382078:515
mexico city:19.42847:-99.12766:2240
new york:40.7127281:-74.006015:10
oslo:59.91386880:10.75224540:1
ottawa:45.424721:-75.695000:70
?(palma d[ae] )ma[lj]?([lj])orca:39.5538874:2.6338597:13
paris:48.8588897:2.320041:35
s[ãa]o paulo:-23.5506507:-46.6333824:760
sydney:-33.865143:151.209900:3
tok[iy]o:35.6812665:139.757653:40"

#script name
SN="${0##*/}"

#geocoordinate regex
GEOREGEX='(-?[0-9]+([.][0-9]+)?)'

#user agent (chrome win10)
UAG='user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36'

#help page
HELP="NAME
	$SN - Weather Forecast from the Norway Meteorologisk Institutt


SYNOPSIS
	$SN [-le] [-gg|-d DIR] [-m ALT] -- [\"LOC\"|[LAT] [LON]] [ALT[m]]
	$SN -s [-m ALT] -- [\"LOC\"|[LAT] [LON]] [DATE] [DAYS] [OFFSET]
	$SN -ce [CITY NAME]
	$SN [-khv]

	Get weather and sunrise data from Meteorologisk Institutt Norway.

	ALT = Altitude, DIR = Directory,
	LAT = Latitude, LON = Longitude, LOC = Location.


DESCRIPTION
	Norway Institute of Meteorology offers model data for weather
	forecast as well as statistics about sun, and moon rise times.


	Weather Forecast
	Defaults function is to retrieve weather forecast information
	and table output.

	Altitude must be provided with option -m, or set as last positional
	parameter in meters such as 500m (main function only), otherwise
	the script tries a request to Open-Elevation public API or prompts
	the elevation to user interactively.

	Set -g to generate X11 or terminal graphs (GNUPlot viewer). Set
	option -gg to force print to dumb terminal.

	Alternatively, set option -d\"DIRECTORY\" to save graph files
	to a directory instead.

	Option -c queries and prints GPS coordinate information from
	OpenStreetMap and OpenCageData APIs.

	Option -k checks main weather API status.

	
	Sunrise and Moon Rise Times
	Option -s retrieves information about sunrise and related times,
	while option -ss retrieves information for the moon.
	
	Note that \"CITY NAME\" must be set as the first positional
	argument, or set latitude and longitude as first and second
	positional arguments.
	
	Further positional arguments are the date, and the time offset.

	Set to empty \"\" if needed. This is a rough implementation!


ENVIRONMENT
	OPENCAGEKEY
		API key from Open Cage (free).

	WFAV
		Favourite locations.

		Each entry must have four fields separated by colons.
		The first field is the location name (glob), the second
		one is latitude, the third one is longitude and the
		fourth is altitude (meters).

		One entry per line, or multiple entries separated with
		semicolon. Ex:

		  export WFAV=\"new york:40.7127281:-74.006015:10;\"


SEE ALSO
	<https://api.met.no/>
	<https://api.met.no/weatherapi/documentation>
	<https://opencagedata.com/api>


WARRANTY
	Licensed under the GNU Public License v3 or better and is distrib-
	uted without support or bug corrections.
   	
	This script requires curl, jq and gnuplot to work properly.

	If you found this useful, please consider sending feedback!  =)


BUGS
	Option -s will not recognise city names with numbers, such as
	\"10 de Abril\", \"12th Street\" and \"Colonia 24 de Febrero\".
	Use actual geo coordinates for these rare location names instead.


OPTIONS
	-b 	Prefer OpenStreetMaps instead of OpenCageData.
	-c \"CITY NAME\"
		Search GPS coordinates from OpenCageData.
	-d DIRECTORY
		Set directory for saving PNG graph images.
	-e 	Print raw JSON.
	-g 	Generate graphs, and open in X11 or print to terminal.
	-gg 	Same as -g, but force printing to dumb terminal.
	-k 	Check weather forecast API status.
	-l 	Print local time.
	-m METRES
		Set altitude, height (integer, metres).
	-s [\"CITY NAME\"|[LAT] [LON]] [DATE] [OFFSET]
		Sunrise and related status.
	-ss 	Same as -s, but get status for moon rise.
	-h 	Help page.
	-v 	Script version."


#plot fun
#-gg plot to dumb term
#usage: plotf [TITLE] [XLABEL] [YLABEL]
plotf()
{
	gnuplot -p \
		-e 'set term dumb' \
		-e "set title \"$1\"; show title; set key off; set xlabel \"$2\"; set ylabel \"$3\"" \
		-e 'set xdata time' \
		-e 'set timefmt "%Y-%m-%dT%H:%M:%S%Z"' \
		-e 'set format x "%b %d"' \
		-e 'plot "-" using 1:2 with linespoints linestyle 1'
}
_plotf() { 	[[ -n $DISPLAY ]] && plotx11f "$@" || plotf "$@" ;}

#-g plot in X11 (gnuplot viewer)
plotx11f()
{
	gnuplot -p \
		-e "set title \"$1\"; show title; set key off; set xlabel \"$2\"; set ylabel \"$3\"" \
		-e 'set xdata time' \
		-e 'set timefmt "%Y-%m-%dT%H:%M:%S%Z"' \
		-e 'set format x "%b %d"' \
		-e 'set grid' \
		-e 'plot "-" using 1:2 with linespoints linestyle 1'
}

#plot to file
plottofilef()
{
	local tmpfile
	tmpfile="${TMPDIR:-/tmp}/${0##*/}.${CITY:-${FORMATTED:-X}}.$1.png"

	gnuplot -p \
		-e "set terminal png size 800,600; set output \"$tmpfile\"" \
		-e "set title \"$1\"; show title; set key off; set xlabel \"$2\"; set ylabel \"$3\"" \
		-e 'set xdata time' \
		-e 'set timefmt "%Y-%m-%dT%H:%M:%S%Z"' \
		-e 'set format x "%b %d"' \
		-e 'plot "-" using 1:2 with linespoints linestyle 1' \
		&& echo "$tmpfile" >&2
}
#https://stackoverflow.com/questions/30315114/show-graph-on-display-and-save-it-to-file-simultaneously-in-gnuplot

#check weather api status
statusf()
{
	curl -\#fL -H "$UAG" 'https://api.met.no/weatherapi/locationforecast/2.0/status' | jq -e
}

#get for location altitude / height
#usage: prompt_altitudef LAT LNG
prompt_altitudef()
{
	if [[ -z $HGT && -n $1 && -n $2 ]]
	then 	printf '%s\n' 'Open-Elevation' >&2;
		HGT=$(
		  curl -\# -fL -X POST https://api.open-elevation.com/api/v1/lookup \
		    -H 'Accept: application/json' \
		    -H 'Content-Type: application/json' \
		    -d "{ \"locations\":
		  [ { 	\"latitude\": ${1}, \"longitude\": ${2}
		    } ] }" | jq -r '.results[0].elevation'
		)
	fi  #https://open-elevation.com/

	if [[ -z $HGT && -n $1 && -n $2 ]]
	then 	printf '%s\n' 'Open-Meteo' >&2;
		HGT=$(
		  curl -\# -fL "https://api.open-meteo.com/v1/elevation?latitude=${1}&longitude=${2}" | jq -r '.elevation[]'
		)
	fi  #https://open-meteo.com/
	
	if [[ -z $HGT ]]
	then 	echo -n "Altitude (meters above sea level): "
		read -r -e HGT
	fi;

	HGT=${HGT%%[Mm,.]*};
	[[ -n $HGT ]] && printf 'Altitude: %d meters\n' "$HGT" >&2;
}

#remove accentuation
rmaccent()
{
	sed 'y/äÄáÁàÀãÃâÂëËéÉèÈẽẼêÊïÏíÍìÌĩĨîÎöÖóÓòÒõÕôÔüÜúÚùÙũŨûÛçÇñÑ/aAaAaAaAaAeEeEeEeEeEiIiIiIiIiIoOoOoOoOoOuUuUuUuUuUcCnN/' || cat
}

#retrieve coordinates by location name and set vars
gpshelperf()
{
	local REPLY query entry data coords jqout x
	query="$*"

	if [[ $query != *[[:alnum:]]* ]]
	then 	return 1
	#contains coordinates?
	elif 	((!OPTC)) &&
		coords=( $(grep -Eom2 "$GEOREGEX" <<<"$query") )
	then 	LAT=${coords[0]} LNG=${coords[1]}
		if [[ -n $LNG ]]
		then  	printf "%s\t%s${HGT:+\t%s}\n" Latitude Longitude ${HGT:+Altitude} "$LAT" "$LNG" $HGT
		else 	unset LAT LNG
		fi
	#favourites
	elif while read -r
		do 	entry="${REPLY%%:*}"
			[[ $entry = *[[:alnum:]]* ]] || continue
			[[ ${query,,} = ${entry,,} ]] || continue
			x=1; break
		done <<<"${WFAV//;/$'\n'}"; ((x))
	then 	printf '%s\n' 'Favourites' >&2
		IFS=: read -r FORMATTED LAT LNG HGT x <<<"$REPLY"
		FORMATTED="${FORMATTED//[[:punct:]]}"
		printf "%s\t%s\t%s${HGT:+\t%s}\n" Name Latitude Longitude ${HGT:+Altitude} "$FORMATTED" "$LAT" "$LNG" $HGT
	#https://stackoverflow.com/questions/3518504/regular-expression-for-matching-latitude-longitude-coordinates
	else
		query=${query//[$IFS]/%20}

		if [[ -n $OPENCAGEKEY ]]
		then 	printf '%s\n' 'OpenCage' >&2
			data=$(curl -\# -fL -H "$UAG" "https://api.opencagedata.com/geocode/v1/json?q=${query}&key=$OPENCAGEKEY&no_annotations=1&language=en")
		else 	#openstreet map
			printf '%s\n' 'OpenStreet Map' >&2
			query=$(rmaccent <<<"$query")
			data=$(curl -\# -fL -H "$UAG" "https://nominatim.openstreetmap.org/search?q=${query}&format=json")
			#max string length 255 chars
		fi

		#-c print coordinates only?
		if ((OPTC))
		then 	if [[ -n $OPENCAGEKEY ]]
			then 	printf '%s\t%s\t%s\t%s\n' Index Latitude Longitude Name
				jq -r '.results[]|(.confidence|tostring)+"\t"+(.geometry.lat|tostring)+"\t"+(.geometry.lng|tostring)+"\t"+.formatted' <<<"$data"
			else 	printf '%-19s\t%-19s\t%s\n' Latitude Longitude Name
				jq -r '.[]|(.lat|tostring)+"\t"+(.lon|tostring)+"\t"+.display_name' <<<"$data"
			fi && LAT=1 LNG=1
		#multiple results
		elif 	if [[ -n $OPENCAGEKEY ]]
			then 	jq -e '.results[1]' <<<"$data"
			else 	jq -e '.[1]' <<<"$data"
			fi >/dev/null 2>&1
		then
			if [[ -n $OPENCAGEKEY ]]
			then 	jqout=$(jq -r '.results[]|(.components|(.town//.city//.village)+", "+.state+", "+.country)+"\t"+(.geometry.lat|tostring)+"\t"+(.geometry.lng|tostring)+"\t"+.formatted' <<<"$data")
			else 	jqout=$(jq -r '.[]|(if .display_name | length > 66 then
				(.display_name|.[0:33])+".."+(.display_name|.[-33:])
				else
				(.display_name)
				end
				)+"\t"+(.lat|tostring)+"\t"+(.lon|tostring)+"\t"+.display_name' <<<"$data")
			fi

			set --
			while read -r
			do 	set -- "$@" "${REPLY%%$'\t'*}"
			done <<<"$jqout"
			select x
			do 	((REPLY&&REPLY<=$#)) && break
			done
			while read -r
			do 	[[ $REPLY = "${x:-@#}"* ]] && break
			done <<<"$jqout"
			IFS=$'\t' read -r x LAT LNG FORMATTED <<<"$REPLY"
			printf "%s\t%s${HGT:+\t%s}\t%s\n" Latitude Longitude ${HGT:+Altitude} Name "$LAT" "$LNG" $HGT "$FORMATTED"
		else  #single result
			if [[ -n $OPENCAGEKEY ]]
			then 	read -r LAT LNG FORMATTED < <(jq -r '.results[0].geometry|(.lat|tostring)+"\t"+(.lng|tostring)' <<<"$data")
				FORMATTED=$(jq -r '.results[0].formatted //empty' <<<"$data")
			else 	read -r LAT LNG FORMATTED < <(jq -r '.[0]|(.lat|tostring)+"\t"+(.lon|tostring)+"\t"+.display_name' <<<"$data")
			fi
			printf "%s\t%s${HGT:+\t%s}\t%s\n" Latitude Longitude ${HGT:+Altitude} Name "$LAT" "$LNG" $HGT "$FORMATTED"
		fi
	fi
	if [[ $LAT = *null* || $LNG = *null* ]] || [[ -z $LAT || -z $LNG ]]
	then 	! printf '%s\n' "${data:-(no data)}" >&2
	fi
}
#https://nominatim.org/release-docs/develop/customize/Postcodes/

#meteorologisk institutt norway
mainf()
{
	local data altitude query jqout header
	if [[ ${@:$#} = +([0-9.,])[Mm] ]]
	then 	HGT=${HGT:-${@:$#}} HGT=${HGT%%[Mm,.]*}
		set -- "${@:1:$#-1}"
	fi
	query="$*"
	[[ $query = *[[:alnum:]]* ]] || query='São Paulo'
	[[ -n $OPTL ]] && local="|strptime(\"%Y-%m-%dT%H:%M:%SZ\")|mktime|strflocaltime(\"%Y-%m-%dT%H:%M:%S%Z\")"

	if ! gpshelperf "$query"
	then 	echo "$0: err: cannot get geo coordinates -- $query" >&2
		return 1
	fi

	prompt_altitudef "$LAT" "$LNG"
	[[ -z $HGT ]] || altitude="&altitude=$HGT"

	#get data
	printf '%s\n' 'Meteorologisk Institutt Norway' >&2
	data=$(curl -\# -fL --compressed -X GET -H "$UAG" -H 'Accept: application/json' "https://api.met.no/weatherapi/locationforecast/2.0/complete?lat=${LAT}&lon=${LNG}${altitude}")
	if ((OPTE))
	then 	printf '%s\n' "$data"
		return
	fi

	#jq '.properties.meta' <<< "$data" >&2  #concerns json field units
	jqout=$(jq -r ".properties.timeseries[] |
\"\(.time$local) \
\(.data.instant.details |
	\"\(.air_temperature // \"?\")ºC \
\(.relative_humidity // \"?\")% \
\(.dew_point_temperature // \"?\")ºC \
\(.fog_area_fraction // \"?\") \
\(.ultraviolet_index_clear_sky // \"?\")UV \
\(.air_pressure_at_sea_level // \"?\")hPa \
\(.wind_speed // \"?\")m/s \
\(.wind_from_direction // \"?\")º \
\(.cloud_area_fraction // \"?\")% \
\(.cloud_area_fraction_high // \"?\")% \
\(.cloud_area_fraction_medium // \"?\")% \
\(.cloud_area_fraction_low // \"?\")%\"
		) \
\(.data.next_1_hours.details |
	\"\(.precipitation_amount // \"?\")mm\") \
\(.data.next_6_hours.details |
	\"\(.precipitation_amount // \"?\")mm \
\(.air_temperature_max // \"?\")ºC \
\(.air_temperature_min // \"?\")ºC\")\"" <<<"$data")
#OBS: there should be more response fields in next_1_hours and 6_hours, according to
#the API scheme format. Those are available only for some geographical areas.
	
	#stats
	header_long="Date,Temp,RelHumidity,DewPoint,FogArea,UVIndex,AirPressureAtSeaLevel,WindSpeed,WindDir,CloudAreaFraction,CloudHighFraction,CloudMediumFraction,CloudLowFraction,PrecipitationNext1h,PrecipitationNext6h,AirMaxNext6h,AirMinNext6h"
	header=Date,Temp,RelHum,DewP,FogA,UV,AirPSea,WinSp,WinDir,ClArea,ClHigh,ClMed,ClLow,Pcpn1h,Pcpn6h,AirMax6h,AirMin6h

	#print tables
	if ((!OPTG)) && [[ -t 1 ]]
	then 	column -et -N"$header" <<<"$jqout" | less -S
	else 	printf '%s\n' "$header" "$jqout"
	fi
	echo "Lat: $LAT  Lng: $LNG  ${HGT:+Alt: $HGT  }${FORMATTED:-$query}" >&2

	#print gfx?
	if ((OPTG))
	then 	jqout=$(tr \? 0 <<<"$jqout" | tr -d 'msº%UVC')  #fix input for graphs
		#colcutf 4 <<<"$jqout" | _plotf DewPoint date ºC &&
		colcutf 10 <<<"$jqout" | _plotf CloudAreaFraction date % &&
		colcutf  3 <<<"$jqout" | _plotf Humidity date % &&
		colcutf  8 <<<"$jqout" | _plotf WindSpeed date m/s &&
		colcutf  7 <<<"$jqout" | _plotf PressureAtSeaLevel date hPa &&
		colcutf 15 <<<"$jqout" | _plotf 'Precipitation(6h)' date mm
		colcutf  2 <<<"$jqout" | _plotf Temperature date ºC
	fi
	return 0
}

#usage: colcutf [COL]
colcutf()
{
	awk "{print \$1,\$${1:-2}}"
}

#sunrise times
#usage: sunrise ["CITY NAME"|[LAT] [LON]] [DATE] [OFFSET]
#!#this function needs improvements
sunrisef()
{
	local arg lat lon data date offset location endpoint n

	if ((OPTS>1))
	then 	endpoint=moon; echo Moon >&2;
	else 	endpoint=sun; echo Sun >&2;
	fi

	#use location name function if criteria met
	for arg
	do 	if [[ $arg != *[0-9]* ]]
		then 	location="${location}${location:+ }${arg}"
		       	n=$((n+1))
		else 	break
		fi
	done
	if gpshelperf "$location"
	then 	set -- "" "" "${@:n+1}"
	elif [[ ! $1 =~ ^$GEOREGEX$ ]] || [[ ! $2 =~ ^$GEOREGEX$ ]]
	then 	echo "$0: err: unknown geo coordinates -- $1 $2" >&2
		return 1
	fi

	#set parameters
	offset="${3:-$(date +%Z:00)}"            #3
	
	date=$(date -d${3:-now} +%Y-%m-%d)       #3
	
	lat="${LAT:-$1}" lon="${LNG:-$2}"        #2 and 1


	data=$(curl -\# -fL -H "$UAG" "https://api.met.no/weatherapi/sunrise/3.0/${endpoint}?lat=${lat}&lon=${lon}&date=${date}&offset=${offset}")
	if ((OPTE))
	then 	printf '%s\n' "$data"
	else 	jq . <<<"$data"
	fi
}


#parse options
while getopts bcd:eghklm:sv1234567890 c
do case $c in
	b) unset OPENCAGEKEY;;
	c) OPTC=1 ;;
	d) if [[ -d $OPTARG ]]
		then 	OPTG=1 TMPDIR="${OPTARG%/}"
			_plotf() { 	plottofilef "$@" ;}
		else 	echo "err: directory is required -- $OPTARG" >&2
			exit 1
		fi ;;
	e) OPTE=1 ;;
	g) ((OPTG++)) && _plotf() { 	plotf "$@" ;} ;;
	h) echo "$HELP"; exit 0 ;;
	k) OPTK=1 ;;  #forecast api status
	l) OPTL=1 ;;  #local time
	m) HGT=${OPTARG%%[Mm,.]*};;  #altitude
	s) ((++OPTS)) ;;  #sunrise, moon rise
	v) grep -m1 '^# v[0-9]' "$0" ;exit ;;
	[0-9.]) ((--OPTIN)) ;break;;
	\?) exit 1 ;;
   esac
done
shift $((OPTIND - 1))
unset c

#check for required pkgs
if ! command -v curl jq &>/dev/null
then 	echo "$0: packages cURL and JQ are required" >&2
	exit 1
elif ((OPTG)) && ! command -v gnuplot &>/dev/null
then 	echo "$0: package GNUPlot is optionally required" >&2
	unset OPTG
fi

#call opt fun
#-k check weather api status
if ((OPTK))
then 	statusf
#-s sunrise stats
elif ((OPTS))
then 	sunrisef "$@"
#-c gps helper
elif ((OPTC))
then 	gpshelperf "$@"
#main, weather fun
else 	mainf "$@"
fi

#               __  ___                  
# _______ ____ / /_/ _ |_    _____ ___ __
#/ __/ _ `(_-</ __/ __ | |/|/ / _ `/ // /
#\__/\_,_/___/\__/_/ |_|__,__/\_,_/\_, / 
#                                 /___/  
#                        __       _                  ___     
#  __ _  ___  __ _____  / /____ _(_)__  ___ ___ ____/ _ )____
# /  ' \/ _ \/ // / _ \/ __/ _ `/ / _ \/ -_) -_) __/ _  / __/
#/_/_/_/\___/\_,_/_//_/\__/\_,_/_/_//_/\__/\__/_/ /____/_/   

