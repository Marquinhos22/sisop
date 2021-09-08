#!/bin/bash

name="demonio"
#nombre de este arch, para buscar luego la rutina que se este ejecutando.

cena(){
    if [ $1 -ge 19 ] #determina si es o no cena
    then
        return 1;
    fi
    return 0;
}

desarrollo(){
    cd $1
    while true; do
    for archivo in $(find . -name "*[0-9].jpg") 
    #itera buscando archivos terminados en jpg
    do
        date=$(echo "$archivo" | grep -oE '[0-9]{8}') 
        #extraer los primeros 8 nros del nombre del archivo            
        hora=$(echo "$archivo" | grep -oE '[0-9]{6}.jpg') 
        #extraer los 6  nros finales del nombre del archivo
        nombre_dia=$(date -d $date +%A)  
        #determina el dia de la semana
        date="${date:0:4}-${date:4:2}-${date:6:2}" 
        #formatea la fecha
        hora="${hora:0:2}" 
        #formatea la hora
    
        if [[ ${2^^} != ${nombre_dia^^} ]]
        then
            cena $hora
            if [[ $? == 1 ]]
                then
                 mv $archivo $(dirname "$archivo")/"$date cena del $nombre_dia.jpg" 
                 #cambia nombre de archivos
                 else
                 mv $archivo $(dirname "$archivo")/"$date almuerzo del $nombre_dia.jpg"
                 fi
        fi
    		done
	done
}

function stop(){

echo "Se esta sellando al demonio: "
var=$(ps -e |grep ${name} |awk '{print $1}' )
#busco el nombre de la ejecucion y guardo el pid.
kill -9 ${var}
}




while test "$1"; do  
    
    case "$1" in

        --help | "-?" | -h)
        echo "help"
        exit 0
        ;;

        --path | -p)
        
	#ejecuto para saber si la rutina ya esta en ejecucion
	# $0 toma el nombre del scrip que lo llama
	if pidof -x $(basename $0) >/dev/null;then
		for p in $(pidof -x $(basename $0));do
			if [ $p -ne $$ ]
				then
					echo "El demonio ya ha sido liberado, para invocarlo nuevamente primero debe sellarlo con -k "
					exit
			fi
		done
	fi
	
        shift
        
        if [[ $2 == -d || $2 == --dia ]]
            then
            desarrollo $1 $3 >/dev/null &
        else
            desarrollo $1 >/dev/null &
        fi
        ;;

        -k)
	stop
        ;;

        #*)
	#        echo $"Usar: $0 {start|stop}"
        #exit 1
    esac
    shift;
done

