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

validarDirectorio() {
	realpath -e "$1" > /dev/null 2>&1
	if [[ $? == 1 ]]; then
		help "La ruta provista en el archivo de configuracion no existe"
	fi

	path=`realpath -e "$1"`

#	path=`dirname "$path"`
	echo "Path a analizar: $path"
	if [[ ! -d "$path" ]]
	then
		help "La ruta provista en el archivo de configuracion no es directorio valido"
	fi
}

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
#Verifico que el unico parametro pasado sea un archivo de configuracion (archivo de texto)
verificarArchivoDeConfiguracion "$1"
fi
# ---------------------------------- FIN VALIDACIONES ----------------------------------

# ---------------------------------- PROGRAMA ----------------------------------
directorioDestino=$(awk 'FNR==1 { print $0 }' "$1")
echo "Validando directorio de destino"
validarDirectorio $directorioDestino
echo "Directorio de destino valido"

listaDirectoriosBase=$(awk ' NR>1 { print $0 }' "$1")
echo "$listaDirectoriosBase"
for d in $listaDirectoriosBase; do
	validarDirectorio "$d"
done

listArchivo=$(awk 'BEGIN { FS = "/" } ; NR>1 {print $(NF-1)}' "$1")
echo "$listArchivo"

ITEMSZIP=()

for d in $listArchivo; do
	fec=$(printf '%(%Y%m%d_%H%M%S)T')
	#echo $fec
	ITEM=logs_$d"_$fec".zip
	echo $ITEM
	ITEMSZIP+=$ITEM
done

echo "BOCA $ITEMSZIP"
exit 1;




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