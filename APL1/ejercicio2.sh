#!/bin/bash
cena(){
    if [ $1 -ge 19 ] #determina si es o no cena
    then
        return 1;
    fi
    return 0;
}

desarrollo(){
    cd $1
    for archivo in $(find . -name "*[0-9].jpg") #itera buscando archivos terminados en jpg
    do
        date=$(echo "$archivo" | grep -oE '[0-9]{8}') #extraer los primeros 8 nros del nombre del archivo
        hora=$(echo "$archivo" | grep -oE '[0-9]{6}.jpg') #extraer los 6  nros finales del nombre del archivo
        nombre_dia=$(date -d $date +%A)  #determina el dia de la semana
        date="${date:0:4}-${date:4:2}-${date:6:2}" #formatea la fecha
        hora="${hora:0:2}" #formatea la hora
    
        if [[ ${2^^} != ${nombre_dia^^} ]]
        then
            cena $hora
            if [[ $? == 1 ]]
                then
                 mv $archivo $(dirname "$archivo")/"$date cena del $nombre_dia.jpg" #cambia nombre de archivos
                 else
                 mv $archivo $(dirname "$archivo")/"$date almuerzo del $nombre_dia.jpg"
                 fi
        fi
    done
}

while test "$1"
do  
    case "$1" in
        --help | "-?" | -h)
        echo "help"
        exit 0
        ;;
        --path | -p)
        shift
        if [[ $2 == -d || $2 == --dia ]]
            then
            desarrollo $1 $3
        else
            desarrollo $1
        fi
        ;;
    esac
    shift;
done
 
