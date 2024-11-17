#!/usr/bin/env bash
# download satellite images from
# Brazilian National Institute of Meteorology
# <https://satelite.inmet.gov.br/>
# by mountaineerbr  ago/2022
# requires curl and jq
# usage: $  inmet.sh  2020-12-15


#choose which image sets to download
URLS=(
	https://apisat.inmet.gov.br/GOES/AS/IV 		#GOES
	#https://apisat.inmet.gov.br/GOESIM/BR/CH 	#GOES+SIMSAT
	#https://apisat.inmet.gov.br/MSG/GL/PHPA 	#GOES+MSG
	#https://apisat.inmet.gov.br/SATELITE/AS/P 	#SATELITE+COSMOS
)

#date
DATE="${1:-$(date -I)}"

#maximum async jobs
JOBMAX=10

#results directory
TEMPD="${TMPDIR:-/tmp}/inmet"

#temp buffers
BUFD="$TEMPD/cache"


cleanf()
{
	trap \  INT HUP EXIT

	pkill -P $$
	wait

	[[ -d "$BUFD" ]] && rm -rf "$BUFD"
	echo -e "\nresults at -- $TEMPD"
	exit
}


trap cleanf INT HUP EXIT

mkdir -pv "$BUFD" || exit

for url in "${URLS[@]}"
do
	((m++))
	data="$BUFD/data.$m.json"
	
	echo
	#json+base64 data
	curl -L -o "$data" --compressed "$url/$DATE" || exit

	#get ids
	IDS=( $(jq -r '.[].id' "$data" ) )

	n=0
	for i in "${IDS[@]}"
	do 	((n++))
		#asynchronous
		{
			buf="$BUFD/$m.$n.buffer.json"

			jq -r ".[]|select(.id==$i)" "$data" > "$buf"

			nome="$(jq -r '"\(.nome)_\(.satelite // "sat")"' "$buf")"
			#ext="$( jq -r '.base64' "$buf" | cut -f1 -d\; | cut -f2 -d/ )"
			ext=jpg
			tgt="$TEMPD/$nome.$ext"

			[[ -e "$tgt" ]] || jq -r '.base64' "$buf" | cut -f2 -d, | base64 -di > "$tgt"
		} &

		echo -ne "url: $m/${#URLS[@]}  file: $n/${#IDS[@]}  \r"

		#bash job control
		while jobs=( $(jobs -p) ) ;((${#jobs[@]} > JOBMAX))
		do 	sleep 0.04
		done
	done
	wait
done

