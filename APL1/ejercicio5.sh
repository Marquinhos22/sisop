#!/bin/bash

# ---------------------------------- AYUDA ----------------------------------
ayuda="
Ayuda correspondiente al script ejercicio5.sh

#OBJETIVO PRINCIPAL#
Este script permite generar archivos .zip en base a logs viejos almacenados

#USO#
Uso: ./ejercicio5.sh archivoDeConfiguracion.txt
Ejemplo: ./ejercicio5.sh /Configuracion/configuracion.txt

#PARAMETROS#
	archivoDeConfiguracion.txt: archivo .txt con los directorios correspondientes

#ACLARACIONES#

"

uso="Uso del script: ./ejercicio5.sh archivoDeConfiguracion.txt"
# ---------------------------------- FIN AYUDA ----------------------------------

# ---------------------------------- FUNCIONES ----------------------------------
# Funcion que muestra mensajes de errores y brinda la ayuda o el uso sobre el script
help() {
	if [[ ! -z $1 ]]; then
		echo "$1. Para consultar la ayuda utilice -h, -? o -help"
		echo "$uso"
	else
		echo "$ayuda"
	fi
	exit 1;
}


# Funcion que valida si el parametro pasado es un directorio (y su existencia como path)
validarDirectorio() {
	#realpath -e "$1" > /dev/null 2>&1
	#if [[ $? == 1 ]]; then
	#	help "La ruta provista en el archivo de configuracion no existe"
	#fi

	#path=`realpath -e "$1"`

#	path=`dirname "$path"`
	echo "Path a analizar: $1"
	if [[ ! -d "$1" ]]
	then
		help "La ruta provista en el archivo de configuracion no es directorio valido"
	fi
}

#
obtenerPathAbsoluto() {
	realpath -e "$1" > /dev/null 2>&1
	if [[ $? == 1 ]]; then
		help "La ruta provista en el archivo de configuracion no existe"
	fi

	echo `realpath -e "$1"`
}

# Funcion que verifica que el archivo de configuracion sea un archivo de texto (.txt)
verificarArchivoDeConfiguracion() {
	path=`realpath "$1"`
	#path=`dirname "$path"`
	echo "Archivo de configuracion a analizar: $path"

	if [[ -f $1 ]]; then
		if [[ $1 != *.txt ]]; then
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

# Obtengo los directorios en donde se encuentran los logs a tratar y los valido
listaDirectoriosBase=(`awk 'NR>1 { print $0 }' "$1"`)

for i in "${!listaDirectoriosBase[@]}"; do
	listaDirectoriosBase[$i]=`obtenerPathAbsoluto "${listaDirectoriosBase[$i]}"`
	validarDirectorio "${listaDirectoriosBase[$i]}"
done

# Obtengo el nombre del directorio padre de cada una de las rutas de directorios de logs
listArchivo=(`awk 'BEGIN { FS = "/" } ; NR>1 {print $(NF-1)}' "$1"`)

# Creo un array conteniendo los nombres de los archivos .zip a crear
ITEMSZIP=()
for i in "${!listArchivo[@]}"; do
	fec=$(printf '%(%Y%m%d_%H%M%S)T')
	ITEM=logs_"${listArchivo[i]}""_$fec.zip"
	ITEMSZIP+=("$ITEM")
done

for i in "${!listaDirectoriosBase[@]}"; do
	cd "${listaDirectoriosBase[i]}"
	#find . -mtime +1 | zip "${ITEMSZIP[i]}" *txt
	find . -mtime +1 -iname '*.txt' -o -iname '*.log' -o -iname '*.info' | zip "$directorioDestino/${ITEMSZIP[i]}" -@ 
done
exit 1
DirectorioZip="${ITEMSDIR[0]}/${ITEMSZIP[1]}"
echo "Archivos del cual debo comprimir " $(realpath ${ITEMSDIR[1]})" ;Archivo zip $DirectorioZip"
zip "$DirectorioZip" "$(realpath ${ITEMSDIR[1]})"
DirectorioZip="${ITEMSDIR[0]}/${ITEMSZIP[2]}"
echo "Archivos del cual debo comprimir " $(realpath ${ITEMSDIR[2]})" ;Archivo zip $DirectorioZip"
zip "$DirectorioZip" "$(realpath ${ITEMSDIR[2]})"
DirectorioZip="${ITEMSDIR[0]}/${ITEMSZIP[3]}"
echo "Archivos del cual debo comprimir " $(realpath ${ITEMSDIR[3]})" ;Archivo zip $DirectorioZip"
zip "$DirectorioZip" "$(realpath ${ITEMSDIR[3]})"
#Luego de Zipear debo eliminar lo zipeado por defecto va a elimianr lo que este en ./tmp/servicios/ubicaciones/
rm -r ${ITEMSDIR[3]}
exit
#############Comprobando funciones sobre los nombres de los directorios
#director="C:/Users/fernando/Desktop/SO 2C 2021/Configuracion/Configuracion.txt"
#dirname "C:/Users/fernando/Desktop/SO 2C 2021/Configuracion/Configuracion.txt"
#basename "C:\Users\fernando\Desktop\SO 2C 2021\Configuracion\Configuracion.txt"
#dir2=${director%/*}
#echo "${director##*/}"
#echo "${director##*.}"
#echo "------------------------"
#echo "$dir2"
#echo "${dir2##*/}"
#echo "<--Nombre: ${d%.*}" "-->"
#echo "<--Extension: ${d##*.}" "-->"
#echo "${director%/*}"
# ---------------------------------- FIN PROGRAMA ----------------------------------