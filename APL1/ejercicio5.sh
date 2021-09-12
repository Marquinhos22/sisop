#!/bin/bash

	###################################
	#                                 #
	#        Trabajo Práctico 1       #
	#          Ejercicio Nº 1         #
	#           ejercicio5.sh         #
	#                                 #
	# Cammarano, Santiago             #
	# DNI: 41.582.407                 #
	#                                 #
	# Ramos, Marcos Gerardo   	      #
	# DNI: 11.111.111                 #
	#                                 #
	# Martel, Lucas             	  #
	# DNI: 39.348.436                 #
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

# ---------------------------------- AYUDA ----------------------------------
ayuda="
Ayuda correspondiente al script ejercicio5.sh

#OBJETIVO PRINCIPAL#
Este script permite generar archivos .zip en base a logs viejos almacenados en rutas provistas en un archivo de configuracion.
Una vez comprimidos, los archivos se deben eliminar para ahorrar espacio en el disco del servidor. 
Se considera antiguo a un archivo de log que no fue creado el día en el que se corre el script(24 hs)

#USO#
Uso: ./ejercicio5.sh archivoDeConfiguracion.txt
Ejemplo: ./ejercicio5.sh ./Configuracion/configuracion.txt

#PARAMETROS#
	archivoDeConfiguracion.txt: archivo .txt con los directorios correspondientes

#ACLARACIONES#
- El archivo de configuracion debe tener la siguiente estructura:
	- En la primera linea la carpeta de destino de los archivos comprimidos
	- A partir de la segunda linea, las rutas donde se encuentran las carpetas de logs a analizar
"

uso="Uso del script: ./ejercicio5.sh archivoDeConfiguracion.txt"
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
			echo $1
	if [[ ! -d "$1" ]]
	then
		echo $1
		help "La ruta provista en el archivo de configuracion no es directorio valido"
	elif [[ ! -r "$1" || ! -w "$1" ]]; then
        help "No se tienen los permisos necesarios sobre el directorio"
	fi
}

# Funcion que obtiene el path absoluto del parametro pasado
obtenerPathAbsoluto() {
	
	realpath -e "$1" > /dev/null 2>&1
	if [[ $? == 1 ]]; then
		echo $1
		help "La ruta provista en el archivo de configuracion no existe"
	fi

	echo `realpath -e "$1"`
}

# Funcion que verifica que el archivo de configuracion sea un archivo de texto (.txt)
verificarArchivoDeConfiguracion() {
	path=`realpath "$1"`
	#path=`dirname "$path"`
	#echo "Archivo de configuracion a analizar: $path"

	if [[ -f "$1" ]]; then
		if [[ "$1" != *.txt ]]; then
			help "El archivo pasado no corresponde a un archivo de configuracion"
			exit 1;
		fi
	else
		help "El archivo pasado no existe"
	fi
}
# ---------------------------------- FIN FUNCIONES ----------------------------------

# ---------------------------------- VALIDACIONES ----------------------------------
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
directorioDestino=$(awk 'FNR==1 { print $0 }' "$1")
directorioDestino=$(obtenerPathAbsoluto "$directorioDestino")
validarDirectorio "$directorioDestino"

# Obtengo el nombre del directorio padre de cada una de las rutas de directorios de logs
nombresDirPadre=(`awk 'BEGIN { FS = "/" } ; NR>1 {print $(NF-1)}' "$1"`)
# Creo un array conteniendo los nombres de los archivos .zip a crear
nombreZips=()
for i in "${!nombresDirPadre[@]}"; do
	#echo $i
	Contador=`expr $i + 2 `
	# Obtengo los directorios en donde se encuentran los logs a tratar y los valido ---------------------------
	listaDirectorio=$(awk ' NR=='$Contador' { print $0 }' "$1")
	#echo $listaDirectorio
	listaDirectoriosBase[$i]=`obtenerPathAbsoluto "$listaDirectorio"`
	#echo ${listaDirectoriosBase[i]}
	fec=$(printf '%(%Y%m%d_%H%M%S)T')
	ITEM=logs_"${nombresDirPadre[i]}""_$fec.zip"
	nombreZips+=("$ITEM")
done

# Entro en cada directorio para buscar los logs viejos, los zipeo y guardo en la carpeta de destino. Finalmente, los elimino
for i in "${!listaDirectoriosBase[@]}"; do
	#ls "${listaDirectoriosBase[i]}" -l
	#echo ${listaDirectoriosBase[i]}
	cd "${listaDirectoriosBase[i]}"
	#usar esta #
	find . -mtime +1 -iname '*.txt' -o -iname '*.log' -o -iname '*.info' | zip -rm "$directorioDestino/${nombreZips[i]}" -@ 
	#find . -mtime +1 -daystart -iname '*.txt' -o -iname '*.log' -o -iname '*.info' | zip "$directorioDestino/${nombreZips[i]}" -@ 
done
# ---------------------------------- FIN PROGRAMA ----------------------------------