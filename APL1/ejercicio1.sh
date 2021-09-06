#!/bin/bash
#funcA
help() {
echo "Error, La sintaxis del script es la siguiente:"
echo "uso: $0 directorio 5" #COMPLETAR
} 

#funcB
error(){
echo "Error. $1 no es un directorio" #COMPLETAR
}

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
#luego va a contar los "\n" ---> casualmente devuelve la cantidad de archivos
#entonces ITEM va a quedar ---> "nroArchivosEnSubdirectorio - nombreSubdirectorio"
ITEMS+=($ITEM) #append el item a ITEMS
done
IFS=$'\n' sorted=($(sort -rV -t '-' -k 1 <<<"${ITEMS[*]}"))
#SORT BY
# -r --> reverse
# -V --> version
# -t --> field separator = SEP --> '-'
# -k --> key --> 1
CANDIDATES="${sorted[*]:0:$2}" #selecciona los primeros X candidatos
unset IFS #IFS vuelve a ser el espacio en blanco
echo "Nombre de archivo" #COMPLETAR
printf "%s\n" "$(cut -d '-' -f 2 <<<"${CANDIDATES[*]}")"
# cut --> print selected parts of lines from each FILE to stdout
# -d --> usar -d como delimitador
# -f --> select only these fields


1. El script cuenta la cantidad de archivos existentes en todos los subdirectorios presentes en el directorio enviado por parametro. Luego, crea una lista, la ordena con cierto orden e imprime los primeros X candidatos, siendo X el segundo parametro pasado al script. 
El script recibe 2 parametros: un directorio y un numero entero
4. Las funciones funcA, funcB y funcC se deberian llamar validar help, error y validarParametros respectivamente
5. Agregaria la validacion del segundo parametro para verificar que sea un numero entero. Ademas, le pasaria el parametro que contiene el directorio a funcB de la siguiente manera: funcB $2. Por otro lado, ante cualquier error en los parametros correspondiente al uso del script, deberia llamar a funcA para explicar dicho uso. Por ultimo, tanto funcA como funcB deberian finalizar con 'exit 1'.
6. La variable $# nos brinda la cantidad de parametros que le fueron pasadas al script.
	$1...${10} : parametros enviados
	$@ o $* : lista de parametros enviados
	$$ : PID del proceso
	$! : PID del ultimo proceso hijo ejecutado en 2do plano
	$? : valor de ejecucion del ultimo comando
7.
'Comillas simples': se utilizan para prevenir que bash interprete cualquier caracter especial dentro de las comillas. En otras palabras, se preserva el valor literal de cada caracter entre comillas. Ejemplo:
$ echo : 'Cualquier $ caracter que se pase aqui \ se mostrara 'literalmente' $'
Salida: Cualquier $ caracter que se pase aqui \ se mostrara 'literalmente' $

"Comillas dobles": tambien preservan el valor literal de cada caracter entre comillas, pero permiten la interpretacion de caracteres especiales como $, `` o \. Ejemplo:
$ var=pepe
$ "Contenido \" de var es: $var"
Salida: Contenido " de var es: pepe
 
`Comillas invertidas`: forzan la ejecucion de los comandos dentro de las comillas. Luego de su ejecucion, la salida de los comandos reemplaza al contenido entre comillas, incluyendo a las mismas. 
Ejemplo: 
$ today=`date '+%A, %B %d, %Y'`
$ echo $today 
Salida: Lunes, Septiembre 06, 2021
8. Si el script es ejecutado sin ningun parametro, se llamara a funcB, la cual devolvera un mensaje de error.
