#!/bin/bash

	###################################
	#                                 #
	#        Trabajo Práctico 1       #
	#          Ejercicio Nº 4         #
	#           ejercicio4.sh         #
	#                                 #
	# Cammarano, Santiago             #
	# DNI: 41.582.407                 #
	#                                 #
	# Ramos, Marcos Gerardo   	      #
	# DNI: 35.896.637                 #
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
Ayuda correspondiente al script ejercicio2.sh

#OBJETIVO PRINCIPAL#
Este script consolida y procesa los archivos .csv de ventas de sucursales en un unico archivo .json

#USO#
Uso: ./ejercicio4.sh <-d directorioEntrada> [-e sucursal] <-o directorioSalida>
Ejemplo de ejecucion: ./ejercicio4.sh -d lotePrueba -o salida -e moron
Ejemplo de ejecucion: ./ejercicio4.sh -d “PathsCSV” -e “Moron” -o “dirSalida
Ejemplo de ejecucion: ./ejercicio4.sh -d “PathsCSV” -o /home/usuario/dirSalida 


#PARAMETROS#
    -d directorio: directorio donde se encuentran los archivos CSV de las sucursales. Subdirectorios incluidos.
    -e sucursal: parámetro opcional que indicará la exclusión de alguna sucursal a la hora de generar el archivo unificado. Solamente se puede excluir una sucursal.
    -o directorio: directorio donde se generará el resumen (salida.json).

#ACLARACIONES#
"

uso="Uso del script: ./ejercicio4.sh <-d directorioEntrada> [-e sucursal] <-o directorioSalida>"
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

# Funcion que valida el directorio pasado por parametros
validarDirectorio() {
    if [[ ! -d "$1" ]]; then
        help "El parametro pasado no es un directorio"
    elif [[ ! -e "$1" ]]; then
        help "No existe la ruta al archivo"
	elif [[ "$2" == "entrada" ]]; then
		if [[ ! -r "$1" ]]; then
        	help "No se tienen los permisos de lectura necesarios sobre el directorio"
		fi
	elif [[ "$2" == "salida" ]]; then
		if [[ ! -w "$1" ]]; then
        	help "No se tienen los permisos de escritura necesarios sobre el directorio"
		fi
    fi
}
# ---------------------------------- FIN FUNCIONES ----------------------------------

# ---------------------------------- VALIDACIONES ----------------------------------
if [[ $# == 0 ]]; then
	help "El script requiere parametros para funcionar"
fi

# Si hay un solo parametro se verifica si es la ayuda o no
if [[ $# == 1 ]]; then
	if [[ $1 == "-h" || $1 == "-?" || $1 == "-help" ]]; then
		help
	fi
fi

# Si hay mas de 6 parametros (cantidad maxima pedida) se informa error
if [[ $# > 6 ]]; then
	help "Error en la cantidad de parametros"
fi

# Si hay menos de 4 parametros (cantidad mknima pedida) se informa error
if [[ $# < 4 ]]; then
	help "Error en la cantidad de parametros"
fi


ARGS=`getopt -q -o d:o:e: -n 'parse-options' -- "$@"`

if [ $? != 0 ]; then
	help "Parametros invalidos";
fi

eval set -- "$ARGS"

while true ; do 
	case "$1" in
	-d ) dirCsv="$2"
		# Valido el directorio de los archivos .csv
		validarDirectorio "$dirCsv" entrada ;
		shift ; shift ;;
	-o ) dirSalida="$2"
		# Valido el directorio de salida
		validarDirectorio "$dirSalida" salida ;
		shift ; shift ;;
  	-e ) noCuenta="${2,,}" ; shift ; shift ;;
  	-- ) shift; break ;;
	* ) break ;;
	esac
done

# Verifico que el directorio de entrada sea distinto al de salida
if [[ "$dirCsv" == "$dirSalida" ]]; then
	help "El directorio de entrada debe ser distinto al de salida"
fi

# Bandera para saber si al menos se procesa un archivo
process=False

# Recorro los archivo .csv del directorio enviado con parametro -d
archivosCsv=(`find $dirCsv -type f -name '*.csv'`)

# Para cada archivo, obtengo su nombre y campos
for i in "${!archivosCsv[@]}"
do
	# Tomo sólo el nombre del archivo sin extension
	nombreArch=$(basename -s .csv ${archivosCsv[i]})

	# Si nombre del archivo es distinto al de la excepcion, proceso
	if [ "${noCuenta}" != "${nombreArch,,}" ]
    then 

		# Consolido los archivo producto(en minusculas)e importe Recaudado a un archivo temporal
		awk 'BEGIN{FS=","}FNR > 1{ print tolower($1)","$2}' ${archivosCsv[i]} >> tempConsolidado
		process=True
	fi

done

# Proceso si tuve al menos un archivo valido
if [ "$process" == True ]
then

	#Agrupo sumando el importe de los mismos productos y ordeno por columna producto a otro archivo temporal
  	awk -f agruparProductos.awk tempConsolidado | sort -k1 >> tempAgrupado

  	#Elimino el archivo temporal de consolidado
	rm tempConsolidado

	#Cuento la cantidad total de productos
  	cantReg=$(wc -l < tempAgrupado)

	#Genero el archivo salida.json en el directorio enviado por parametro -o
  	awk -f jsonGeneratorAwk.awk -v cantReg="$cantReg" tempAgrupado > "$dirSalida/salida.json"

  	#Elimino el archivo temporal de agrupamiento
	rm tempAgrupado
fi