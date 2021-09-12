#!/bin/bash

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
	help;
	exit 1;
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

  	-e ) noCuenta="${2,,}" ; shift ; shift ;;
	
  	-- ) shift; break ;;
	* ) break ;;
	esac
done

#bandera para saber si al menos se procesa un archivo
process=False

#Recorro los archivo .csv del directorio enviado con parametro -d
for archCsv in "$(find $dirCsv -type f -name '*.csv')"
do
	#Tomo sólo el nombre del archivo sin extension
	nombreArch=$(basename -s .csv $archCsv)
    
	#echo "no cuenta: $noCuenta"
	#echo "nombre archivo: $nombreArch"
    
	#Si nombre del archivo es distinto al de la excepcion, proceso
	if [ "$noCuenta" != "${nombreArch,,}" ]
    then 
		# consolido los archivo producto(en minusculas),Importe Recaudado a un archivo temporal
		awk 'BEGIN{FS=","}FNR > 1{ print tolower($1)","$2}' $archCsv >> tempConsolidado
		process=True
    else
		echo "Por aqui!! no pasa"
	fi

done

#Proceso si tuve al menos un archivo valido
if [ $process == True ]
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