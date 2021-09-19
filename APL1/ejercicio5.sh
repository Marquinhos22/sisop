#!/bin/bash

	###################################
	#                                 #
	#        Trabajo Práctico 1       #
	#          Ejercicio Nº 5         #
	#           ejercicio5.sh         #
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
	# 	      1º Reentrega     	  	  #
	#                                 #
	###################################

# ---------------------------------- AYUDA ----------------------------------
ayuda="
Ayuda correspondiente al script ejercicio5.sh

#OBJETIVO PRINCIPAL#
Este script permite generar archivos .zip en base a logs viejos almacenados en rutas provistas en un archivo de configuracion.
Una vez comprimidos, los archivos se deben eliminar para ahorrar espacio en el disco del servidor. 
Se considera antiguo a un archivo de log que no fue creado el día en el que se corre el script(24 hs).

#USO#
Uso: ./ejercicio5.sh archivoDeConfiguracion.txt
Ejemplo: ./ejercicio5.sh ./Configuracion/configuracion.txt

#PARAMETROS#
	archivoDeConfiguracion.txt: archivo .txt con los directorios correspondientes.
	-h | -? | -help: ayuda sobre el script.

#ACLARACIONES#
- El archivo de configuracion debe tener la siguiente estructura:
	- En la primera linea la carpeta de destino de los archivos comprimidos
	- A partir de la segunda linea, las rutas donde se encuentran las carpetas de logs a analizar
"

uso="Uso del script: ./ejercicio5.sh <archivoDeConfiguracion.txt>"
# ---------------------------------- FIN AYUDA ----------------------------------

# ---------------------------------- FUNCIONES ----------------------------------
# Funcion que muestra mensajes de errores y brinda la ayuda o el uso sobre el script
help() {
	if [[ ! -z "$1" ]]; then
		echo "$1. Para consultar la ayuda utilice -h, -? o -help"
		echo "$uso"
	else
		echo "$ayuda"
	fi
	exit 1;
}

# Funcion que valida si el parametro pasado es un directorio (y su existencia como path)
validarDirectorio() {
	echo \"$1\" 
	if [[ ! -d "$1" ]]; then
		echo "---------------"
		help " La ruta provista: \"$1\"  en el archivo de configuracion no es directorio valido"
	elif [[ ! -e "$1" ]]; then
        help "No existe la ruta al archivo  \"$1\" "
	elif [[ ! -r "$1" || ! -w "$1" ]]; then
        help "No se tienen los permisos necesarios sobre el directorio  \"$1\" "
	fi
}

# Funcion que obtiene el path absoluto del parametro pasado
obtenerPathAbsoluto() {
	echo "`realpath -e "$1"`"
}

# Funcion que verifica que el archivo de configuracion sea un archivo de texto (.txt)
verificarArchivoDeConfiguracion() {
	if [[ -f "$1" ]]; then
		if [[ "$1" != *.txt ]]; then
			help "El archivo pasado: \"$1\" no corresponde a un archivo de configuracion"
			exit 1;
		fi
	else
		help "El archivo pasado: \"$1\"  no existe"
	fi
}
# ---------------------------------- FIN FUNCIONES ----------------------------------

# ---------------------------------- VALIDACIONES ----------------------------------
# Muevo directorios por si llaman al script desde un lugar relativo
scriptPath=`realpath $0`
scriptPath=`dirname "$scriptPath"`
cd "$scriptPath"

# Si no se pasaron parametros al script se informa error
if [[ $# == 0 ]]; then
	help "El script requiere parametros para funcionar"
fi

# Si hay mas de un parametro (cantidad pedida) se informa error
if [[ $# > 1 ]]; then
	help "Error en la cantidad de parametros"
fi

# Si hay un solo parametro se verifica si es la ayuda o el parametro pedido
if [[ $# == 1 ]] ; then
	if [[ $1 == "-h" || $1 == "-?" || $1 == "-help" ]]; then
		help
	fi
	
# Verifico que el unico parametro pasado sea un archivo de configuracion (archivo de texto)
verificarArchivoDeConfiguracion "$1"
fi
# ---------------------------------- FIN VALIDACIONES ----------------------------------

# ---------------------------------- PROGRAMA ----------------------------------
# Obtengo el directorio de destino de los .zip y lo valido (si es una ruta valida y si es un directorio)
# Se cambio al awk anterior para leer la linea completa del archivo y validar desde el inicio
while IFS= read -r line
do

	# Valido (si es una ruta valida y si es un directorio) la linea que obtengo en la lectura
	validarDirectorio "$line"
	listaDirBases+=("$line")
done <"$1"

# Empiezo a separar las rutas segun destino y lectura
directorioDestino=`obtenerPathAbsoluto "${listaDirBases[0]}"`

# Separo las rutas segun lectura para que coincidan los subindices con los obtenidos en el awk (desde [1]->>>[n])
directoriosZip=("${listaDirBases[@]:1:${#listaDirBases[@]}}")

#Controlar los subindice del array
Contador=0
#Controlar las iteraciones del awk
Control=1

while [ "$Control" -le "${#directoriosZip[@]}" ]; 
do	
	listaDirectoriosBase[$Contador]=`obtenerPathAbsoluto "${directoriosZip[Contador]}"`
	let Control=$Control+1
	let Contador=$Contador+1

	# Obtengo los directorios padre de los archivo para generar el nombre del zip
	NombreBaseZip=`awk 'BEGIN { FS = "/" } ; NR=='$Control' {print $(NF-1)}' "$1"`

	# Obtengo la fecha actual
	fec=$(printf '%(%Y%m%d_%H%M%S)T')

	# Genero el nombre del archivo .zip correspondiente
	ITEM=logs_"$NombreBaseZip""_$fec.zip"

	listanombreZips+=("$ITEM")
done

# Entro en cada directorio para buscar los logs viejos, los zipeo y guardo en la carpeta de destino. Finalmente, los elimino
for i in "${!listaDirectoriosBase[@]}"; do
	cd "${listaDirectoriosBase[i]}"

	# El siguiente find nos genero ciertas inconsistencias con los archivos del dia anterior a la ejecucion del script, segun su hora de modificacion
	#find . -daystart -mtime +1  -iname '*.txt' -o -iname '*.log' -o -iname '*.info' | -rm zip "$directorioDestino/${listanombreZips[i]}" -@ 

	# Busco los archivos que no son mas recientes que la fecha actual (00:00:00)
	find . ! -newermt '00:00:00'  -iname '*.txt' -o -iname '*.log' -o -iname '*.info' | -rm zip "$directorioDestino/${listanombreZips[i]}" -@ 
done
# ---------------------------------- FIN PROGRAMA ----------------------------------