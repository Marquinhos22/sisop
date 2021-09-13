#!/bin/bash

	###################################
	#                                 #
	#        Trabajo Práctico 1       #
	#          Ejercicio Nº 4         #
	#           recopilar.sh          #
	#                                 #
	# Cammarano, Santiago             #
	# DNI: 41.582.407                 #
	#                                 #
	# Ramos, Marcos Gerardo   	  #
	# DNI: 11.111.111                 #
	#                                 #
	# Martel, Lucas             	  #
	# DNI: 39.348.436                 #
	#                                 #
	# Rius Conde, Lucio      	  #
	# DNI: 41.779.534   		  #
	#  				  #
	# Sullca, Fernando Willian        #
	# DNI: 37.841.788	          #
	#                                 #
	# 	      1º Entrega     	  #
	#                                 #
	###################################

function help {

    echo ".....................................Descripcion:............................................"
    echo "El script consolida y procesa los archivos .csv de ventas de sucursales en un unico archivo .json"
    echo ""
    echo "El script recibe los siguientes parametros:"
    echo -e "\n\t-d directorio: directorio donde se encuentran los archivos CSV de las sucursales. Subdirectorios incluidos."
    echo -e "\n\t-e sucursal: parámetro opcional que indicará la exclusión de alguna sucursal a la hora de generar el archivo unificado. Solamente se puede excluir una sucursal."
    echo -e "\n\t-o directorio: directorio donde se generará el resumen (salida.json)."
    
	echo -e "\nEjemplo de ejecucion: ./recopilar.sh -d lotePrueba -o salida -e moron" 
    
    echo -e "\nEjemplo de ejecucion: ./recopilar.sh -d “PathsCSV” -e “Moron” -o “dirSalida”" 
    echo -e "\nEjemplo de ejecucion: ./recopilar.sh -d “PathsCSV” -o /home/usuario/dirSalida" 
}

if [ "$1" = "-help" ] || [ "$1" = "-?" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]
then
    help
    exit 0
fi

#Validacion de envio de parametros

ARGS=`getopt -q -o d:o:e: -n 'parse-options' -- "$@"`

if [ $? != 0 ]
then
	echo -e "\nParametros inválidos.\n"
	echo -e "$0 -? | -h | --help para ayuda"
	exit 0
fi

eval set -- "$ARGS"

while true ; do 
	
	case "$1" in

	-d ) dirCsv="$2"
		#Validaciones para el directorio de los archivos .csv
		if [[ ! -d $dirCsv ]]
		then
			echo "$dirCsv no existe o no es un directorio"
			echo -e "$0 -? | -h | --help para ayuda"
			exit 0
		fi
		
		if [[ ! -r $dirCsv ]]
		then
			echo "No tiene permisos de lectura para el directorio: $dirCsv"
			echo -e "$0 -? | -h | --help para ayuda"
			exit 0
		fi ; shift ; shift ;;

	-o ) dirSalida="$2"
		#Validaciones para el directorio de los archivos .csv
		if [[ ! -d $dirSalida ]]
		then
			echo "$dirSalida no existe o no es un directorio"
			echo -e "$0 -? | -h | --help para ayuda"
			exit 0
		fi
			
		if [[ ! -w $dirSalida ]]
		then
			echo "No tiene permisos de escritura para el directorio: $dirSalida"
			echo -e "$0 -? | -h | --help para ayuda"
			exit 0
		fi ; shift ; shift ;;
	#Al tomar el valor de sucursal a ignorar lo paso a minusculas por ser no case sensitive
  	-e ) noCuenta="${2,,}" ; shift ; shift ;;
	
  	-- ) shift; break ;;
	* ) break ;;
	esac
done

#
recorrerCSV() {

	for archCsv in $sucursales
	do
		#Tomo sólo el nombre del archivo sin extension ni ruta
		nombreArch=$(basename -s .csv $archCsv)
			
		#valido que el archivo no este vacio
		if [ -s "$archCsv" ]
		then
			#Si nombre del archivo es distinto al de la excepcion, lo proceso
			if [ "$noCuenta" != "${nombreArch,,}" ]
			then 
				#consolido los archivo producto(en minusculas) + Importe Recaudado a un archivo temporal
				awk 'BEGIN{FS=","}FNR > 1{ print tolower($1)","$2}' $archCsv >> tempConsolidado
				process=True
			fi

		else
			#Si esta vacio lo acumulo en una varible
			sucursalesVacias+=($nombreArch)
		fi

	done

}

# Funcion que obtiene el path absoluto del parametro pasado
obtenerPathAbsoluto() {
	echo `realpath -e "$1"`
}

#Borro archivos temporales
borrarTemporales() {

	rm tempConsolidado
	rm tempAgrupado

}

#Muestra las sucursales donde los archivos fallaron y estan vacios
mostrarSucursalesVacias() {

	if [ ${sucursalesVacias[*]} ]
	then
		echo -e "\nLas siguientes sucursales tuvieron error en sus archivos:"
		echo -e "${sucursalesVacias[*]}"
	else
		echo -e "\nNo hubo errores en las sucursales procesadas."		
	fi

}
#Borro archivos temporales
procesarSucursales() {

	#Agrupo sumando el importe de los mismos productos y ordeno por columna producto a otro archivo temporal
  	awk -f agruparProductos.awk tempConsolidado | sort -k1 >> tempAgrupado

	#Cuento la cantidad total de productos
  	cantReg=$(wc -l < tempAgrupado)
	#Genero el archivo salida.json en el directorio enviado por parametro -o
  	awk -f jsonGeneratorAwk.awk -v cantReg="$cantReg" tempAgrupado > "$dirSalidaAbs/salida.json"
	
}

sucursalesVacias=()

dirCsvAbs="`obtenerPathAbsoluto "$dirCsv"`"
dirSalidaAbs="`obtenerPathAbsoluto "$dirSalida"`"

#valido que el path de salida no sea el mismo que el de archivos csv
if [ "$dirCsvAbs" == "$dirSalidaAbs" ]
then
	echo -e "\nEl directorio de salida no puede ser el mismo que el directorio a analizar."
	echo -e "\n$0 -? | -h | --help para ayuda"
	exit 0

fi

sucursales=$(find $dirCsvAbs -type f -name '*.csv')

#bandera para saber si al menos se procesa un archivo
process=False

#Recorro los archivo .csv del directorio enviado con parametro -d
recorrerCSV

#Proceso si tuve al menos un archivo valido
if [ $process == True ]
then
	procesarSucursales
	borrarTemporales
	mostrarSucursalesVacias
fi
