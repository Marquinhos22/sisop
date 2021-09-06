#!/bin/bash

#Funcion que nunca es llamada
funcA() {
echo "Error. La sintaxis del script es la siguiente:"
echo "$0 directorio_recorrer cantidad_elementos" 
}

#Funcion que muestra un mensaje de error cuando el parametro $1 no es un directorio valido.
funcB() {
echo "Error. $1 No es un directorio valido."
}

#Funcion que valida que el primer parametro enviado sea un directorio valido.
funcC() {
if [[ ! -d $2 ]]; then
funcB
fi
}

funcC $# $1 $2 $3 $4 $5

#Guarda un listado de directorios a a partir de el directorio raiz pasado por parametro.
LIST=$(ls -d $1*/)

ITEMS=()
#Recoorre los subdirectorios y guarda su cantidad de elementos y nombre 
for d in $LIST; do
ITEM="`ls $d | wc -l`-$d"
ITEMS+=($ITEM)
done

#Guarda en una variable, el listado anterior ordenado por la cantidad de elementos
IFS=$'\n' sorted=($(sort -rV -t '-' -k 1 <<<"${ITEMS[*]}"))

# Recorta el listado ordenado desde el 1er elemento hasta el numero de elementos pasado como parametro $2 
CANDIDATES="${sorted[*]:0:$2}"
unset IFS
printf "Top $2 de subdirectorios que contienen más elementos: \n"

# Separa y muestra los subdirectorios cortando la cantidad de elementos por el cual se ordenaron.
printf "%s\n" "$(cut -d '-' -f 2 <<<"${CANDIDATES[*]}")"

#Responda:
#1. ¿Cuál es el objetivo de este script? ¿Qué parámetros recibe?
# El objetivo es mostrar un listado de subdirectorios ordenados de mayor a menor por la cantidad de elementos que contienen a raiz de un directorio raiz
# Recibe dos parametros: $1 el directorio raiz, en el cual se desea analizar los subdirectorios y $2 la cantidad a mostrar de subdirectorios ordenados 
#2. Comentar el código según la funcionalidad (no describa los comandos, indique la lógica).
#3. Completar los “echo” con los mensajes correspondientes.
#4. ¿Qué nombre debería tener las funciones funcA, funcB, funcC?
#    funcA: help()
#    funcB: mostrar_error()
#    funcC: valida_directorio()
#5. ¿Agregaría alguna otra validación a los parámetros? ¿Existe algún error en el script?
#   Si, validar que la cantidad de parametros sea 2 y que el parametro $2 sea un numero valido (positivo).
#   Si, las variables ${CANDIDATES[*]} e ${ITEMS[*]} no estaban correctamente encomilladas para ser interpretadas correctamente.
#6. ¿Qué información brinda la variable $#? ¿Qué otras variables similares conocen?
#   $# muestra la cantidad de parametros que recibe el script.
#   $@ lista todos los parámetros separados por comillas.
#   $* muestra los parametros como una sola cadena de texto.
#   $? muestra el resultado de la ultima ejecucion de comando.  
#7. Expliquen las diferencias entre los distintos tipos de comillas que se pueden utilizar en shell scripts (bash).
# Simples: representan valores literales.
# Dobles: se utiliza para representar valores de variables con $
# Invertidas: es una forma de guardar valores de comandos utilizados
#8. ¿Qué sucede si se ejecuta el script sin ningún parámetro?
# Sale mensaje de error por parametro $1 como directorio invalido.
