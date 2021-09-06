#!/bin/bash

#funcA
help() {
echo "Error, La sintaxis del script es la siguiente:"
echo "uso: $0 directorio 5" #COMPLETAR
} 

#funcB
error() {
echo "Error. $1 no es un directorio" #COMPLETAR
}

#funcC
validarParametros() {
if [[ ! -d $2 ]]; then
error
fi
}
validarParametros $# $1 $2 $3 $4 $5 #validar parametros de entrada
LIST=$(ls -d $1*/)
ITEMS=() # variable vacia
for d in $LIST; do #para cada directorio de LIST
ITEM="`ls $d | wc -l` -$d"
ITEMS+=($ITEM) #append el item a ITEMS
done
IFS=$'\n' sorted=($(sort -rV -t '-' -k 1 <<<${ITEMS[*]}))
CANDIDATES="${sorted[*]:0:$2}" #selecciona los primeros X candidatos
unset IFS #IFS vuelve a ser el espacio en blanco
echo "Subdirectorios" #COMPLETAR
printf "%s\n" "$(cut -d '-' -f 2 <<<${CANDIDATES[*]})"
