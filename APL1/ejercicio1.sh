#!/bin/bash
#funcA
help() {
echo "Error, La sintaxis del script es la siguiente:"
echo "uso: $0 directorio 5" #COMPLETAR
} 

#funcB
error(){
echo "Error. $1 no es un directorio" #COMPLETAR}

#funcC
validarParametros(){
if [[ ! -d $2 ]]; then
error
fi
}
validarParametros $# $1 $2 $3 $4 $5 #validar parametros de entrada
LIST=$(ls -d $1*/)
# LIST = `ls -d $1/` --> otra forma
# ls -d lista todos las directory entries en el parametro que se le pase (no lista contenidos)
# */ expande solo a los directorios
# entonces agregandole -d solo te traes los directorios dentro del parametro pasado
# EJEMPLO: ls -d * ---> Desktop		Test
#	   ls -d */ ---> Desktop/	Test/
ITEMS=() # variable vacia
for d in $LIST; do #para cada directorio de LIST
ITEM="`ls $d | wc -l` -$d"
#para cada directorio del parametro pasado, va a entrar en el mismo con ls $d
#luego va a contar los "\n" ---> casualmente devuelve la cantidad de directorios
#entonces ITEM va a quedar ---> "nroDirectorios -nombredirectorio/"
ITEMS+=($ITEM) #append el item a ITEMS
done
IFS=$'\n' sorted=($(sort -rV -t '-' -k 1 <<<${ITEMS[*]}))
#SORT BY
# -r --> reverse
# -V --> version
# -t --> field separator = SEP --> '-'
# -k --> key --> 1
CANDIDATES="${sorted[*]:0:$2}" #selecciona los primeros X candidatos
unset IFS #IFS vuelve a ser el espacio en blanco
echo "Subdirectorios" #COMPLETAR
printf "%s\n" "$(cut -d '-' -f 2 <<<${CANDIDATES[*]})"
# cut --> print selected parts of lines from each FILE to stdout
# -d --> usar -d como delimitador
# -f --> select only these fields