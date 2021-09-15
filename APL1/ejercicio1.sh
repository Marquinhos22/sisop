#!/bin/bash

	###################################
	#                                 #
	#        Trabajo Práctico 1       #
	#          Ejercicio Nº 1         #
	#           ejercicio1.sh         #
	#                                 #
	# Cammarano, Santiago             #
	# DNI: 41.582.407                 #
	#                                 #
	# Martel, Lucas                   #
	# DNI: 39.348.436                 #
	#                                 #
	# Ramos, Marcos Gerardo           #
	# DNI: 35.896.637                 #
	#                                 #
	# Rius Conde, Lucio        	  	  #
	# DNI: 41.779.534 		  		  #
	# 				  				  #
	# Sullca, Fernando Willian        #
	# DNI: 37.841.788		  	      #
	#                                 #
	# 	      1º Entrega     	  	  #
	#                                 #
	###################################

# ------------------------------------------------------------------

# Muestra un mensaje indicando el uso del script
help() {
	echo "Error, La sintaxis del script es la siguiente:"
	echo "$0 <directorio cantDeSubdir>: $0 directorio 5"
	exit 1;
} 

# Muestra un mensaje de error cuando el parametro $1 del script no es un directorio valido
noEsDirectorio() {
	echo "Error. $1 no es un directorio"
	exit 1;
}

# Valida que el primer parametro enviado sea un directorio valido
validarDirectorio() {
	if [[ ! -d $2 ]]; then
		noEsDirectorio $2
	fi
}

# Validar parametros de entrada
validarDirectorio $# $1 $2 $3 $4 $5

# Guarda una lista los subdirectorios/ presentes en el directorio raiz pasado por parametro
LIST=$(ls -d $1*/)

# Crea un array vacio
ITEMS=()

# Para cada subdirectorio del directorio pasado por parameto, se cuenta la cantidad de elementos presentes
# Tambien se agrega el nombre del subdirectorio en cuestion
for d in $LIST; do
	# Formato de ITEM ---> "nroelementosEnSubdirectorio-nombreSubdirectorio"
	ITEM="`ls $d | wc -l` -$d"

	# Agrega ITEM en una nueva posicion de ITEMS
	ITEMS+=($ITEM) 
done

# Cambia el Input Field Separator por '\n'
# Guarda en un array, el listado anterior ordenado por la cantidad de elementos (de mayor a menor)
# -r --> orden inverso (mayor a menor)
# -V --> indica que solo se ordenan numeros
# -t '-' --> indica el '-' como campo separador
# -k 1 --> compara solo por el campo 1, tomando a todo el contenido de ITEMS
IFS=$'\n' sorted=($(sort -rV -t '-' -k 1 <<<${ITEMS[*]}))

#Crea un nuevo array donde se guarda una cantidad $2 (segundo parámetro enviado en el script) de subdirectorios ordenados
CANDIDATES="${sorted[*]:0:$2}"

# El IFS vuelve a ser el espacio en blanco
unset IFS 

# Muestra el listado generado de subdirectorios (solo el nombre de los mismos, presente en el ultimo campo)
echo "Subdirectorios ordenados por cantidad de elementos que contienen: "
printf "%s\n" "$(cut -d '-' -f 2 <<<${CANDIDATES[*]})"

# ------------------------------------------------------------------

# 1. El objetivo del script es mostrar un listado de subdirectorios (de un directorio pasado por parametro) ordenados de mayor a menor por la cantidad de elementos que contienen. La cantidad maxima de subdirectorios a mostrar se pasa tambien por parametro.
# El script recibe 2 parametros: un directorio y un numero que repesenta la cantidad de subdirectorios a mostrar.
# 
# 4. funcA: help
#    funcB: noEsDirectorio
#    funcC: validarDirectorio
# 
# 5. Agregaria/cambiaria:
#	- Validar que la cantidad de parametros sea 2 y que el parametro $2 sea un numero valido (natural positivo)
#	- Pasarle el parametro que contiene el directorio a funcB de la siguiente manera: funcB $2
#	- Ante cualquier error en los parametros correspondiente al uso del script, deberia llamar a funcA para explicar dicho uso
#	- Tanto funcA como funcB deberian finalizar con 'exit 1'
#	- Las variables ${CANDIDATES[*]} e ${ITEMS[*]} no estaban correctamente encomilladas para ser interpretadas correctamente
#
# 6. La variable $# nos brinda la cantidad de parametros que le fueron pasadas al script.
#	$1...${10} : parametros enviados
#	$@ o $* : lista de parametros enviados
#	$$ : PID del proceso
#	$! : PID del ultimo proceso hijo ejecutado en 2do plano
#	$? : valor de ejecucion del ultimo comando
# 
# 7.
# 'Comillas simples': se utilizan para prevenir que bash interprete cualquier caracter especial dentro de las comillas. En otras palabras, se preserva el valor literal de cada caracter entre comillas. Ejemplo:
# $ echo : 'Cualquier $ caracter que se pase aqui \ se mostrara 'literalmente' $'
# Salida: Cualquier $ caracter que se pase aqui \ se mostrara 'literalmente' $

# "Comillas dobles": tambien preservan el valor literal de cada caracter entre comillas, pero permiten la interpretacion de caracteres especiales como $, `` o \. Ejemplo:
# $ var=pepe
# $ "Contenido de var es: $var"
# Salida: Contenido de var es: pepe
 
# `Comillas invertidas`: forzan la ejecucion de los comandos dentro de las comillas. Luego de su ejecucion, la salida de los comandos reemplaza al contenido entre comillas, incluyendo a las mismas. 
# Ejemplo: 
# $ today=`date '+%A, %B %d, %Y'`
# $ echo $today 
# Salida: Lunes, Septiembre 06, 2021
#
# 8. Si el script es ejecutado sin ningun parametro, se llamara a funcB, la cual devolvera un mensaje de error.
# Al no colocar "exit 1" en funcB, el script ejecutara su contenido y mostrara un array vacio (CANDIDATES).

