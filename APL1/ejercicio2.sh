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

# ---------------------------------- AYUDA ----------------------------------
ayuda="
Ayuda correspondiente al script ejercicio2.sh

#OBJETIVO PRINCIPAL#
Este script permite renombrar los archivos (en formato .jpg que sigan una determinada estructura en su nombre) presentes en el directorio pasado por parametro.
El script admite un parametro obligatorio que es la ruta del directorio y un parametro opcional que es el nombre de un dia para el cual no se quieren renombrar los archivos.

#USO#
Uso: ./ejercicio2.sh <-p directorio> [-d diaDeLaSemana]
Ejemplo: ./ejercicio2.sh -p APL1/ -d martes

#PARAMETROS#
    -p | --path directorio: directorio donde se encuentran los archivos.
    -d | --dia diaDeLaSemana: nombre de un dia para el cual no se quieren renombrar los archivos. Acepta minuscula y mayuscula. Sin tildes.
	-h | -? | -help: ayuda sobre el script.

#ACLARACIONES#
- El dia de la semana a excluir se puede ingresar en español o en ingles
"

uso="Uso del script: ./ejercicio2.sh <-p directorio> [-d diaDeLaSemana]"
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

# Funcion que valida si el dia de la semana pasado como parametro opcional es valido o no
validarDiaSemana() {
    semana=(lunes martes miercoles jueves viernes sabado domingo)
    semanaIngles=(monday tuesday wednesday thursday friday saturday sunday)
    flag=0
    for i in "${!semana[@]}"
    do
        if [[ ${1,,} == ${semana[i]} || ${1,,} == ${semanaIngles[i]} ]]; then
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
	echo `realpath -e "$1"`
}

# Funcion que valida el directorio pasado por parametros
validarDirectorio() {
    if [[ ! -d "$1" ]]; then
        help "El parametro pasado no es un directorio"
    elif [[ ! -e "$1" ]]; then
        help "No existe la ruta al archivo"
    elif [[ ! -r "$1" || ! -w "$1" ]]; then
        help "No se tienen los permisos necesarios sobre el directorio"
    fi
}

# Funcion que valida lo siguiente:
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

# Funcion que determina si el archivo corresponde a una cena o no
esCena() {
    if [ $1 -ge 19 ]; then
        return 1;
    fi
    return 0;
}

# Funcion que renombra los archivos del directorio pasado por parametro y sus subdirectorios correspondientes
renombrarArchivos() {
    echo "--------- Renombrando archivos ---------"

    # Ingreso al directorio pasado por parametros
    cd "$1"

    # Para cada archivo (con el formato correspondiente) dentro del directorio
    fotos=($(find ./ -regextype posix-extended -regex '.*([0-9]{4})(0[1-9]|1[0-2])(0[1-9]|[1-2][0-9]|3[0-1])\_(2[0-3]|[01][0-9])([0-5][0-9])([0-5][0-9]).(jpg)$'))
    for i in ${!fotos[@]} # Iterar buscando archivos terminados en .jpg
    do
        # Extraer los primeros 8 nros del nombre del archivo
        date=$(echo "${fotos[i]}" | grep -oE '[0-9]{8}') 

        # Extraer los 6 nros finales del nombre del archivo
        hora=$(echo "${fotos[i]}" | grep -oE '[0-9]{6}.jpg') 

        # Determina el dia de la semana y lo convierto a minuscula
        nombre_dia=$(date -d $date +%A)
        nombre_dia=${nombre_dia,}
        echo "$nombre_dia"

        # Formatea la fecha
        date="${date:0:4}-${date:4:2}-${date:6:2}" 

        # Formatea la hora
        hora="${hora:0:2}" 
    
        # Verifico si se quiere excluir un dia en base al parametro pasado
        if [[ ${2^^} != ${nombre_dia^^} ]]; then
            # Averiguo si la foto corresponde a una cena o a un almuerzo en base a la hora
            esCena $hora

            if [[ $? == 1 ]]; then
                mv ${fotos[i]} $(dirname "${fotos[i]}")/"$date cena del $nombre_dia.jpg"
            else
                mv ${fotos[i]} $(dirname "$fotos[i]")/"$date almuerzo del $nombre_dia.jpg"
            fi
        fi
    done

    echo "--------- Proceso finalizado ---------"
    exit 0;
}
# ---------------------------------- FIN FUNCIONES ----------------------------------

# ---------------------------------- VALIDACIONES ----------------------------------
# Si no se pasaron parametros al script se informa error
if [[ $# == 0 ]]; then
	help "El script requiere parametros para funcionar"
fi

# Si hay un solo parametro se verifica si es la ayuda o no
if [[ $# == 1 ]]; then
	if [[ $1 == "-h" || $1 == "-?" || $1 == "-help" ]]; then
		help
	fi
fi

# Si hay mas de 4 parametros (cantidad maxima pedida) se informa error
if [[ $# > 4 ]]; then
	help "Error en la cantidad de parametros"
fi
# ---------------------------------- FIN VALIDACIONES ----------------------------------

# ---------------------------------- PROGRAMA ----------------------------------
while test "$1"
do  
    case "$1" in
        --path | -p) shift ;
        validarDirectorio "$1" ;
        dir="`obtenerPathAbsoluto "$1"`"
        validarParametrosOpcionales "$2" "$3"
        if [[ $? == 1 ]]; then
            renombrarArchivos "$dir"
        else
            renombrarArchivos "$dir" "$3"
        fi
        exit 0;
        ;;
        * ) help "Parametros incorrectos" ; break ;;
    esac
done
# ---------------------------------- FIN PROGRAMA ----------------------------------

