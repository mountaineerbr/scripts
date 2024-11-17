#!/usr/bin/env bash
# v0.4.5  by mountaineerbr  GPLv3+
# imagens de radar do ipmet e simepar
# Instituto de Pesquisas Meteorológicas (UNESP)
# Sistema de Tecnologia e Monitoramento Ambiental do Paraná

#image viewer
IMGVIEWER="${IMGVIEWER:-feh}"

#tempo entre conexões
#ipmet
SLEEP=6m
#simepar
SLEEP_SIM=10m
#on error
SLEEPERR=30m

#temp dir
TEMPD="${TMPDIR:-/tmp}/ipmet"

#keep track of process
PIDFILE="${TEMPD%/}/ipmet.pid"

HELP=" 	ipmet.sh -- Imagens de Radar do IPMET e SIMPEPAR

	ipmet.sh [-hl]
	ipmet.sh [-ss] [-L TEMPO] 
	
	O script puxa a última imagem de radar do IPMET ou SIMEPAR e a
	abre com $IMGVIEWER . Por padrão, acessa o radar do IPMET.

	Pode-se puxar imagens repetidamente com a opção -l e setar o
	tempo entre reconexões com opção -L TEMPO, em que TEMPO é um
	argumento entendido por \`sleep'.

	Diretório de cache: $TEMPD .


	Opções
	-h 	Exibir esta página de ajuda.
	-l 	Puxar imagens repetidamente a cada $SLEEP .
	-L TEMPO
		Mesmo que -l e configura tempo entre reconexões.
	-s
	-ss	A última imagem do SIMEPAR, ou as oito últimas."


#imagem de radar simepar
#http://www.simepar.br/prognozweb/simepar/radar_msc
simeparf()
{
	local name time ret baseurl referer prev
	baseurl=https://lb01.simepar.br/riak/pgw-radar
	referer=Referer:http://www.simepar.br/
	name="product${1:-1}.jpeg"
	
	printf -v time '%(%Y-%m-%dT%H_%M)T' -1 || time=$(date -Iseconds)
	TEMPFILE="${TEMPD%/}/simepar_${time}${2}.jpg"

	if ((OPTS>1))
	then 	for prev in 8 7 6 5 4 3 2
		do 	OPTS=1 simeparf $prev _$prev; ((ret+=$?)); sleep 0.4
		done
	fi
	
	curl -L --compressed --header "$referer" "$baseurl/$name" -o "$TEMPFILE"; ((ret+=$?))

	echo "$TEMPFILE"
	return $ret
}

#imagem de radar ipmet
#https://www.ipmetradar.com.br/2imagemRadar.php
ipmetf()
{
	local data name info time ret baseurl referer
	baseurl=https://www.ipmetradar.com.br/ipmet_html/radar
	referer=Referer:https://www.ipmetradar.com.br/2imagemRadar.php

	data=$( curl -L --compressed "$baseurl/2carga_img.php" )
	name=$( sed -nE 's/.*(nova.jpg\?[0-9]+).*/\1/p' <<<"$data" )
	info=$( sed -nE 's/.*(Imagem Composta dos Radares.*)<.*/\1/p' <<<"$data" )
	time=$( grep -Eo '[0-9]+/[0-9]+/[0-9: ]+$' <<<"$info" )
	TEMPFILE="${TEMPD%/}/ipmet_${time//[^a-zA-Z0-9]/_}.jpg"

	if [[ ! -s "$TEMPFILE" ]]
	then 	curl -L --compressed --header "$referer" "$baseurl/$name" -o "$TEMPFILE"; ((ret+=$?))
	fi

	echo "$info" >&2
	echo "$TEMPFILE"
	return $ret
}

#trap function
trapf()
{
	trap \  INT TERM
	exit
}


#opções
while getopts hlL:s c
do  case $c in
        h) 	echo "$HELP" ;exit ;;
        l) 	OPTLOOP=1 ;;
	L) 	OPTLOOP=1 SLEEP="$OPTARG" SLEEP_SIM="$OPTARG" ;;
	s) 	((++OPTS)) ;;
        \?) 	exit 1 ;;
    esac
done ;unset c
shift $((OPTIND -1))


[[ -d "$TEMPD" ]] || mkdir -pv "$TEMPD" || exit

#loop or open image
if ((OPTLOOP))
then
	trap trapf INT TERM
	tee -a "$PIDFILE" <<<$$ 
	while true
	do 	if ((OPTS))
		then 	chk_old=$chk;  #diff old and new imgs
			chk=$(OPTS=1 simeparf);
			if [[ -e $chk && -e $chk_old ]] &&
			   diff -q -- "$chk" "$chk_old" &>/dev/null
			then 	rm -v -- "$chk"; chk=$chk_old;
			fi
			echo "$chk";
		else 	ipmetf;
		fi &&
		sleep $SLEEP || sleep $SLEEPERR;
	done
else
	if ((OPTS));
	then 	simeparf;
	else 	ipmetf;
	fi &&
	( "$IMGVIEWER" "$TEMPFILE" & )
fi

