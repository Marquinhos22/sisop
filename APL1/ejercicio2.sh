#!/bin/bash

	###################################
	#                                 #
	#        Trabajo Práctico 1       #
	#          Ejercicio Nº 2         #
	#           ejercicio2.sh         #
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
Ayuda correspondiente al script ejercicio2.sh

#OBJETIVO PRINCIPAL#
Este script permite renombrar los archivos (en formato .jpg que sigan una determinada estructura en su nombre) presentes en el directorio pasado por parametro.
El script admite un parametro obligatorio que es la ruta del directorio y un parametro opcional que es el nombre de un dia para el cual no se quieren renombrar los archivos.

#USO#
Uso: ./ejercicio2.sh <-p [-d]>
Ejemplo: ./ejercicio2.sh -p APL1/ -d martes

#PARAMETROS#
    -p, --path: directorio donde se encuentran los archivos.
    [-d, --dia]: nombre de un dia para el cual no se quieren renombrar los archivos. Acepta minuscula y mayuscula. Sin tildes.

#ACLARACIONES#


"

uso="Uso del script: ./ejercicio2.sh <-p [-d]>"
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

# Aqui se valida si el dia de la semana pasado como parametro opcional es valido o no
validarDiaSemana() {
    semana=(lunes martes miercoles jueves viernes sabado domingo)
    flag=0
    for dia in "${semana[@]}"
    do
        : 
        if [[ ${1,,} == $dia ]]; then
            flag=1;
        fi
    done

    if [[ $flag != 1 ]]; then
            help ""$1" no es un dia de la semana"
            exit 1;
    fi
}

# Funcion que obtiene el path absoluto del parametro pasado
obtenerPathAbsoluto() {
	realpath -e "$1" > /dev/null 2>&1
	if [[ $? == 1 ]]; then
		help "La ruta provista en el archivo de configuracion no existe"
	fi

	echo `realpath -e "$1"`
}

# Aqui se valida el directorio pasado por parametros
validarDirectorio() {
    if [[ ! -d $1 ]]; then
        help "El parametro pasado no es un directorio"
    elif [[ ! -e $1 ]]; then
        help "No existe la ruta al archivo"
    elif [[ ! -r $1 || ! -w $1 ]]; then
        help "No se tienen los permisos necesarios sobre el directorio"
    fi
}

# Aqui se valida lo siguiente:
#   - Si se ingreso un parametro opcional, que sea el pedido por el script
#       - Si el parametro opcional es correcto, que se haya ingresado un dia de la semana
#           - Si se ingreso un dia de la semana, que sea valido
validarParametrosOpcionales() {
    if [ ! -z $1 ]; then
        if [[ ! ($1 == "-d" || $1 == "--dia") ]]; then
            help ""$1" no es un parametro valido"
        elif [[ -z $2 ]]; then
            help ""$2" no es un parametro valido"
        fi
    else
        return 1;
    fi

    validarDiaSemana $2
}

# Determina si el archivo corresponde a una cena o no
esCena() {
    if [ $1 -ge 19 ]; then
        return 1;
    fi
    return 0;
}

# Aqui se renombran los archivos del directorio pasado por parametro y sus subdirectorios correspondientes
renombrarArchivos() {
    echo "--------- Renombrando archivos ---------"
    cd $1
    for archivo in $(find . -name "*[0-9].jpg") # Iterar buscando archivos terminados en .jpg
    do
        date=$(echo "$archivo" | grep -oE '[0-9]{8}') # Extraer los primeros 8 nros del nombre del archivo
        hora=$(echo "$archivo" | grep -oE '[0-9]{6}.jpg') # Extraer los 6 nros finales del nombre del archivo
        nombre_dia=$(date -d $date +%A)  # Determina el dia de la semana
        date="${date:0:4}-${date:4:2}-${date:6:2}" # Formatea la fecha
        hora="${hora:0:2}" # Formatea la hora
    
        if [[ ${2^^} != ${nombre_dia^^} ]]; then
            esCena $hora
            if [[ $? == 1 ]]; then
                mv $archivo $(dirname "$archivo")/"$date cena del $nombre_dia.jpg" # Cambia nombre de archivos
            else
                mv $archivo $(dirname "$archivo")/"$date almuerzo del $nombre_dia.jpg"
            fi
        fi
    done

    echo "--------- Proceso finalizado ---------"
}
# ---------------------------------- FIN FUNCIONES ----------------------------------

# ---------------------------------- VALIDACIONES ----------------------------------
# Si no se pasaron parametros al script se informa error
if [[ $# == 0 ]]; then
	echo "El script requiere parametros para funcionar. Para consultar la ayuda utilice -h, -? o -help"
	echo "$uso"
	exit 1
fi

# Si hay un solo parametro se verifica si es la ayuda o no
if [[ $# == 1 ]]; then
	if [[ $1 == "-h" || $1 == "-?" || $1 == "-help" ]]; then
		echo "$ayuda"
		exit 1;
	fi
fi

# Si hay mas de 4 parametros (cantidad maxima pedida) se informa error
if [[ $# > 4 ]]; then
	echo "Error en la cantidad de parametros. Para consultar la ayuda utilice -h, -? o -help"
	echo "$uso"
	exit 1;
fi

# ---------------------------------- FIN VALIDACIONES ----------------------------------


# ---------------------------------- PROGRAMA ----------------------------------
while test "$1"
do  
    case "$1" in
        --path | -p) shift ;
        dir=`obtenerPathAbsoluto "$1"`
        validarDirectorio "$dir" ;
        validarParametrosOpcionales "$2" "$3"
        if [[ $? == 1 ]]; then
            renombrarArchivos "$1" ;
        else
            renombrarArchivos "$1" "$3" ;
        fi
        ;;
        * ) help "Parametros incorrectos" ; break ;;
    esac
    #shift;
done
# ---------------------------------- FIN PROGRAMA ----------------------------------

