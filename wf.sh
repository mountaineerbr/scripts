#!/usr/bin/env bash
# wf.sh  --  weather forecast from the norway meteorological institute
# v0.9.1  jan/2026  by mountaineerbr

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
	$SN [-eu] [-gg|-d \"DIR\"] [-m ALT] -- [\"LOC\"|[LAT] [LON]] [ALTm] [DATE]
	$SN -s [-m ALT] [\"LOC\"|[LAT] [LON]] [DATE] [DAYS] [OFFSET]
	$SN -ce [LOCATION]
	$SN [-khv]

	Get weather, sun and moon rise data from the Meteorologisk
	Institutt of Norway.


	ALT = Altitude (meters), DATE = YYYY-MM-DD, DIR = Directory,
	LOC = Location Name, LAT = Latitude, LON = Longitude,
	OFFSET = [+-]HH:MM.


DESCRIPTION
	Norway Institute of Meteorology offers model data for weather
	forecast as well as statistics about sun, and moon rise times.


	Weather Forecast

	Defaults function is to retrieve weather forecast information
	and table output.

	Altitude must be provided with option -m, or set as positional
	argument after the geo corrdinates or location name. If set as
	positional parameter, it must follow the format \"500m\".

	If no altitude is provided, the script tries making a request to
	Open-Elevation or Open-Meteo public APIs, or it prompts the elevation
	to the user interactively.

	Set option -g to generate X11 or terminal graphs with GNUPlot.
	Set options -gg to force print to dumb terminal.

	Alternatively, set option -d\"DIRECTORY\" to save graph image
	files to a directory instead.

	Option -u prints time in UTC instead of local time.

	Option -k checks main weather API status.


	Open-Meteo API

	To request the weather forecast (table output), use -w. This behaves
	similarly to the default Norwegian Meteorological Institute mode.
	Combine with -g to generate graphs.

	To print a summary of current weather conditions, use -ww.


	Geo Coordinate APIs

	This script queries OpenStreetMap (free) or OpenCageData for geo
	coordinates (when envar \$OPENCAGEKEY is set), and
	Open-Elevation or Open-Meteo for altitude info.
	
	Option -c queries and prints GPS coordinate information only.


	Sunrise and Moon Rise Times

	Option -s retrieves information about sunrise and moonrise
	related times (from the Norway Institute of Meteorology).
	
	Note that \"CITY NAME\" must be set as the first positional
	argument, or set latitude and longitude as first and second
	positional arguments.
	
	Further positional arguments are the date, and the time offset.
	Set to positional parameters to empty \"\" if needed.


ENVIRONMENT
	OPENCAGEKEY
		API key from Open Cage (free).

	WFAV 	Favourite locations.

		Each entry must have four fields separated by colons.
		The first field is the location name (glob), the second
		one is latitude, the third one is longitude and the
		fourth is altitude (meters above sea level).

		One entry per line, or multiple entries separated with
		semicolon. Ex:

		  export WFAV=\"new york:40.7127281:-74.006015:10;\"


SEE ALSO
	<https://api.met.no/weatherapi/documentation>
	<https://www.openstreetmap.org>
	<https://opencagedata.com/api>
	<https://open-elevation.com>
	<https://open-meteo.com>


WARRANTY
	Licensed under the GNU Public License v3 or better and is distrib-
	uted without support or bug corrections.
   	
	This script requires cURL, JQ and GNUPlot to work properly.


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
	-h 	Print this help page.
	-k 	Check weather forecast API status.
	-m METRES
		Set altitude, height (integer, metres).
	-s [\"LOCATION\"|[LAT] [LON]] [DATE] [OFFSET]
		Sunrise and moonrise status.
	-u 	Use UTC time.
	-v 	Script version.
	-w 	Forecast from Open-Meteo (use -g for graphs).
	-ww 	Current weather conditions from Open-Meteo."


#plot fun
#plot to dumb term
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

#plot in X11 (gnuplot viewer)
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
	iconv -f utf-8 -t ascii//TRANSLIT 2>/dev/null ||
	perl -Mutf8 -CS -pe 'tr/äÄáÁàÀãÃâÂëËéÉèÈẽẼêÊïÏíÍìÌĩĨîÎöÖóÓòÒõÕôÔüÜúÚùÙũŨûÛçÇñÑ/aAaAaAaAaAeEeEeEeEeEiIiIiIiIiIoOoOoOoOoOuUuUuUuUuUcCnN/' 2>/dev/null || 
	sed -e 'y/äÄáÁàÀãÃâÂëËéÉèÈẽẼêÊïÏíÍìÌĩĨîÎöÖóÓòÒõÕôÔüÜúÚùÙũŨûÛçÇñÑ/aAaAaAaAaAeEeEeEeEeEiIiIiIiIiIoOoOoOoOoOuUuUuUuUuUcCnN/' 2>/dev/null ||
	cat
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
		FORMATTED=${FORMATTED//?\]} FORMATTED=${FORMATTED//[[:punct:]]}
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

		if ((OPTC && OPTE))
		then 	printf '%s\n' "$data"
			return
		#-c print coordinates only?
		elif ((OPTC))
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
			then 	jqout=$(jq -r '.results[]|(.components|(._normalized_city//.town//.city//.municipality//.village)+", "+(.state//.province//.neighbourhood)+", "+.country)+"\t"+(.geometry.lat|tostring)+"\t"+(.geometry.lng|tostring)+"\t"+.formatted' <<<"$data")
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
	local data altitude query jqout header ret

	if [[ ${@:$#} = [0-9]*[Mm] ]]
	then
		HGT=${HGT:-${@:${#}}};
		set -- "${@:1:${#}-1}";
	elif ((${#}>1)) && [[ ${@:${#}-1:1} = [0-9]*[Mm] ]]
	then
		HGT=${HGT:-${@:${#}-1:1}};
		set -- "${@:1:${#}-2}" "${@:${#}}";
	fi; HGT=${HGT%%[Mm,.]*};

	query="$*"
	[[ $query = *[[:alnum:]][[:alnum:]]* ]] || query='São Paulo'
	((OPTL)) || local="|strptime(\"%Y-%m-%dT%H:%M:%SZ\")|mktime|strflocaltime(\"%Y-%m-%dT%H:%M:%S%Z\")"

	if ! gpshelperf "$query"
	then 	! echo "$SN: err: cannot get geo coordinates -- $query" >&2
		return 1
	fi

	prompt_altitudef "$LAT" "$LNG"
	[[ -z $HGT ]] || altitude="&altitude=$HGT"

	#get data
	printf '%s\n' 'Meteorologisk Institutt Norway' >&2
	data=$(curl -\# -fL --compressed -X GET -H "$UAG" -H 'Accept: application/json' "https://api.met.no/weatherapi/locationforecast/2.0/complete?lat=${LAT}&lon=${LNG}${altitude}")
	ret=$((ret+$?));

	if ((OPTE))
	then 	printf '%s\n' "$data"
		return
	fi

	jqout=$(jq -r ".properties.timeseries[] |
	  (.data.instant.details // {}) as \$i |
	  (.data.next_1_hours.details // {}) as \$n1 |
	  (.data.next_6_hours.details // {}) as \$n6 |
	  \"\(.time${local}) \
	\(\$i.air_temperature // \"?\")ºC \
	\(\$i.relative_humidity // \"?\")% \
	\(\$i.dew_point_temperature // \"?\")ºC \
	\(\$i.fog_area_fraction // \"?\") \
	\(\$i.ultraviolet_index_clear_sky // \"?\")UV \
	\(\$i.air_pressure_at_sea_level // \"?\")hPa \
	\(\$i.wind_speed // \"?\")m/s \
	\(\$i.wind_from_direction // \"?\")º \
	\(\$i.cloud_area_fraction // \"?\")% \
	\(\$i.cloud_area_fraction_high // \"?\")% \
	\(\$i.cloud_area_fraction_medium // \"?\")% \
	\(\$i.cloud_area_fraction_low // \"?\")% \
	\(\$n1.precipitation_amount // \"?\")mm \
	\(\$n6.precipitation_amount // \"?\")mm \
	\(\$n6.air_temperature_max // \"?\")ºC \
	\(\$n6.air_temperature_min // \"?\")ºC\"" <<<"$data")
	ret=$((ret+$?));
	#.properties.meta - concerns about value units.
	#.probability_of_precipitation - only some locations.
	#next_1_hours and next_6_hours may have additional data for some locations.
	
	header_long="Date,Temp,RelHumidity,DewPoint,FogAreaFrac,UVIndex,AirPressureAtSeaLevel,WindSpeed,WindDir,CloudAreaFraction,CloudHighFraction,CloudMediumFraction,CloudLowFraction,Precipitation1h,Precipitation6h,AirMaxTemp6h,AirMinTemp6h"
	header=Date,Temp,RelHum,DewP,FogFrac,UV,AirPSea,WinSp,WinDir,ClArea,ClHigh,ClMed,ClLow,Pcpn1h,Pcpn6h,AirMax6h,AirMin6h
	#1:Date    2:Temp    3:RelHum   4:DewP      5:FogA     6:UV
	#7:AirPSea 8:WinSp   9:WinDir  10:ClArea   11:ClHigh  12:ClMed
	#13:ClLow 14:Pcpn1h 15:Pcpn6h  16:AirMax6h 17:AirMin6h
        
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
		colcutf 14 <<<"$jqout" | _plotf 'Precipitation(1h)' date mm &&
		colcutf 15 <<<"$jqout" | _plotf 'Precipitation(6h)' date mm &&
		colcutf  2 <<<"$jqout" | _plotf Temperature date ºC
	fi 2>/dev/null || ! echo "$SN: err: GNUPlot" >&2;

	return $((ret+$?))
}

#open-meteo
mainf_omf()
{
	local data altitude query jqout header url ret
	local _z _tz_hour sign val tz

	if [[ ${@:$#} = [0-9]*[Mm] ]]
	then
		HGT=${HGT:-${@:${#}}};
		set -- "${@:1:${#}-1}";
	elif ((${#}>1)) && [[ ${@:${#}-1:1} = [0-9]*[Mm] ]]
	then
		HGT=${HGT:-${@:${#}-1:1}};
		set -- "${@:1:${#}-2}" "${@:${#}}";
	fi; HGT=${HGT%%[Mm,.]*};

	query="$*"
	[[ $query = *[[:alnum:]][[:alnum:]]* ]] || query='São Paulo'

	if ! gpshelperf "$query"
	then 	! echo "$SN: err: cannot get geo coordinates -- $query" >&2
		return 1
	fi

	#prompt_altitudef "$LAT" "$LNG"
	[[ -z $HGT ]] || altitude="$HGT"

	if ((OPTL))
	then
		tz="GMT"
	else  #timezone
		if (( BASH_VERSINFO[0] >= 4 )); then
		    _z=$(printf '%(%z)T' -1)
		else
		    _z=$(date +%z)
		fi

		# 2. Extract the sign and the hour
		# We take the first 3 characters: -03 or +05
		_tz_hour=${_z:0:3}
		
		# 3. Format for Open-Meteo (GMT-3)
		# Strip leading zero from the hour if it's not the only digit
		# e.g., -03 becomes -3, +05 becomes +5
		# Using parameter expansion to strip '0' after the sign
		sign=${_tz_hour:0:1}
		val=${_tz_hour:1:2}
		tz="GMT${sign}${val##0}"
	fi

	#get data
	printf '%s\n' 'Open-Meteo' >&2
	if ((OPTW>1))
	then
		#current weather
		url="https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LNG}&current=temperature_2m,relative_humidity_2m,wind_speed_10m,wind_direction_10m,precipitation,cloud_cover&timezone=${tz}&elevation=${altitude:-nan}"

		data=$(curl -\# -fL --compressed -X GET -H "$UAG" -H 'Accept: application/json' "$url")
		ret=$((ret+$?));

		if ((OPTE))
		then 	printf '%s\n' "$data"
			return
		fi
		echo "Lat: $LAT  Lng: $LNG  ${HGT:+Alt: $HGT  }${FORMATTED:-$query}" >&2

		jq -r '
		  (.current // {}) as $c |
		  (.current_units // {}) as $u |
		  [
		    ["METRIC", "VALUE", "UNIT"],
		    ["------", "-----", "----"],
		    ["Cloud_Cover", ($c.cloud_cover // "?"), ($u.cloud_cover // "")],
		    ["Precipitation", ($c.precipitation // "?"), ($u.precipitation // "")],
		    ["Wind_Direction", ($c.wind_direction_10m // "?"), ($u.wind_direction_10m // "")],
		    ["Wind_Speed", ($c.wind_speed_10m // "?"), ($u.wind_speed_10m // "")],
		    ["Humidity", ($c.relative_humidity_2m // "?"), ($u.relative_humidity_2m // "")],
		    ["Temperature", ($c.temperature_2m // "?"), ($u.temperature_2m // "")]
		  ] | .[] | @tsv
		' <<<$data | column -t -s $'\t' || ! jq . <<<$data >&2;
	else
		#detailed forecast
		url="https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LNG}&daily=precipitation_sum,precipitation_hours&hourly=temperature_2m,relative_humidity_2m,precipitation,pressure_msl,cloud_cover,wind_speed_80m&timezone=${tz}&elevation=${altitude:-nan}&forecast_days=16"

		data=$(curl -\# -fL --compressed -X GET -H "$UAG" -H 'Accept: application/json' "$url")
		ret=$((ret+$?));

		if ((OPTE))
		then 	printf '%s\n' "$data"
			return
		fi

		jqout=$(jq -r '
		  (.hourly // {}) as $h | (.hourly_units // {}) as $u |
		  ["TIMESTAMP", "TEMPERATURE", "HUMIDITY", "PRECIP", "PRESSURE", "CLOUDS", "WIND"],
		  ["---------", "-----------", "--------", "------", "--------", "------", "----"],
		  (range($h.time // [] | length) as $i | [
		    ($h.time[$i] // "?"),
		    "\($h.temperature_2m[$i] // "?") \($u.temperature_2m // "")",
		    "\($h.relative_humidity_2m[$i] // "?") \($u.relative_humidity_2m // "")",
		    "\($h.precipitation[$i] // "?") \($u.precipitation // "")",
		    "\($h.pressure_msl[$i] // "?") \($u.pressure_msl // "")",
		    "\($h.cloud_cover[$i] // "?") \($u.cloud_cover // "")",
		    "\($h.wind_speed_80m[$i] // "?") \($u.wind_speed_80m // "")"
		  ])
		  | @tsv
		' <<<$data)
		ret=$((ret+$?));

		#print tables
		if ((!OPTG)) && [[ -t 1 ]]
		then 	column -t -s $'\t' <<<"$jqout" | less -S
		else 	printf '%s\n' "$jqout"
		fi
		echo "Lat: $LAT  Lng: $LNG  ${HGT:+Alt: $HGT  }${FORMATTED:-$query}" >&2

		#print gfx?
		if ((OPTG))
		then 	jqout=$(tr \? 0 <<<"$jqout" | tr -d 'msº°%UVChPakm/h')  #fix input for graphs
			colcutf  6 <<<"$jqout" | _plotf CloudAreaFraction date % &&
			colcutf  3 <<<"$jqout" | _plotf Humidity date % &&
			colcutf  7 <<<"$jqout" | _plotf WindSpeed date km/h &&
			colcutf  5 <<<"$jqout" | _plotf PressureAtSeaLevel date hPa &&
			colcutf  4 <<<"$jqout" | _plotf 'Precipitation(1h)' date mm &&
			colcutf  2 <<<"$jqout" | _plotf Temperature date ºC
		fi 2>/dev/null || ! echo "$SN: err: GNUPlot" >&2;
	fi

	return $((ret+$?))
}

#usage: colcutf [COL]
colcutf()
{
	awk "{print \$1,\$${1:-2}}"
}

#sunrise times
#usage: sunrise ["CITY NAME"|[LAT] [LON]] [DATE] [OFFSET]
sunrisef()
{
	local arg lat lon datas datam date offset location n

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
	then 	! echo "$SN: err: unknown geo coordinates -- $1 $2" >&2
		return 1
	fi

	#set parameters
	offset="${4:-$(date +%Z:00)}" || offset=$(printf '%(%Z:00)T' -1);
	[[ $offset = [+-][0-9][0-9]:[0-9][0-9] ]] || echo "err: offset format -- \"[+-]HH:MM\"" >&2;
	
	date=$(date ${3:+ -d"$3"} +%Y-%m-%d) || date=$(printf '%(%Y-%m-%d)T' -1);

	lat="${LAT:-$1}" lon="${LNG:-$2}";
	
	datam=$(curl -\# -fL -H "$UAG" "https://api.met.no/weatherapi/sunrise/3.0/moon?lat=${lat}&lon=${lon}&date=${date}&offset=${offset}")
	datas=$(curl -\# -fL -H "$UAG" "https://api.met.no/weatherapi/sunrise/3.0/sun?lat=${lat}&lon=${lon}&date=${date}&offset=${offset}")

	if ((OPTE))
	then 	printf '%s\n' "$datas" "$datam";
	else 	{
		jq -r '
		  [
		    ["EVENT", "TIME", "AZIMUTH", "ELEVATION", "VISIBLE"],
		    ["Moonrise", .properties.moonrise.time, .properties.moonrise.azimuth, "", ""],
		    ["Moonset", .properties.moonset.time, .properties.moonset.azimuth, "", ""],
		    ["High Moon", .properties.high_moon.time, "", .properties.high_moon.disc_centre_elevation, .properties.high_moon.visible],
		    ["Low Moon", .properties.low_moon.time, "", .properties.low_moon.disc_centre_elevation, .properties.low_moon.visible]
		  ]
		  | (.[0], .[1:][]) | @tsv' <<<"$datam";
		jq -r '
		  [
		    ["EVENT", "TIME", "AZIMUTH", "ELEVATION", "VISIBLE"],
		    ["Sunrise", .properties.sunrise.time, .properties.sunrise.azimuth, "", ""],
		    ["Sunset", .properties.sunset.time, .properties.sunset.azimuth, "", ""],
		    ["Solar Noon", .properties.solarnoon.time, "", .properties.solarnoon.disc_centre_elevation, .properties.solarnoon.visible],
		    ["Solar Midnight", .properties.solarmidnight.time, "", .properties.solarmidnight.disc_centre_elevation, .properties.solarmidnight.visible]
		  ]
		  | (.[0], .[1:][]) | @tsv' <<<"$datas";
		} | column -t -s $'\t';
	fi
}


#parse options
while getopts bcd:eghklum:svw1234567890 c
do case $c in
	b) OPENCAGEKEY= OPENCAGE_API_KEY= ;;
	c) OPTC=1 ;;
	d) if [[ -d $OPTARG ]]
		then 	OPTG=1 TMPDIR="${OPTARG%/}"
			_plotf() { 	plottofilef "$@" ;}
		else 	! echo "err: directory is required -- $OPTARG" >&2
			exit 1
		fi ;;
	e) OPTE=1 ;;
	g) ((OPTG++)) && _plotf() { 	plotf "$@" ;} ;;
	h) echo "$HELP"; exit 0 ;;
	k) OPTK=1 ;;  #forecast api status
	l|u) OPTL=1 ;;  #utc time
	m) HGT=${OPTARG%%[Mm,.]*};;  #altitude
	s) OPTS=1 ;;  #sunrise, moon rise
	v) grep -m1 '^# v[0-9]' "$0" ;exit ;;
	w) ((++OPTW)) ;;
	[0-9.]) ((--OPTIN)) ;break;;
	\?) exit 1 ;;
   esac
done
shift $((OPTIND - 1))
unset c

OPENCAGEKEY=${OPENCAGEKEY:-$OPENCAGE_API_KEY};

#check for required pkgs
if ! command -v curl jq &>/dev/null
then 	echo "$SN: packages cURL and JQ are required" >&2
	exit 1
elif ((OPTG)) && ! command -v gnuplot &>/dev/null
then 	echo "$SN: package GNUPlot is optionally required" >&2
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
#open-meteo
elif ((OPTW))
then 	mainf_omf "$@"
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

