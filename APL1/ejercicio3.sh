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

# ---------------------------------- AYUDA ----------------------------------
ayuda="
Ayuda correspondiente al script ejercicio3.sh

#OBJETIVO PRINCIPAL#
Este script permite renombrar los archivos (en formato .jpg que sigan una determinada estructura en su nombre) presentes en el directorio pasado por parametro.
Para realizar esto, ejecuta un demonio en segundo plano que monitorea el directorio pasado por parametros en busca de archivos con el formato correspondiente.
El script admite un parametro obligatorio que es la ruta del directorio y un parametro opcional que es el nombre de un dia para el cual no se quieren renombrar los archivos.
Ademas, el script admite un parametro opcional para detener el mismo si es que se esta ejecutando.

#USO#
Uso: ./ejercicio3.sh <-p directorio> [-d diaDeLaSemana] [-k]
Ejemplo para ejecutar el demonio: ./ejercicio3.sh -p APL1/ -d martes
Ejemplo para detener el demonio: ./ejercicio3.sh -k

#PARAMETROS#
    -p, --path directorio: directorio donde se encuentran los archivos.
    [-d, --dia diaDeLaSemana]: nombre de un dia para el cual no se quieren renombrar los archivos. Acepta minuscula y mayuscula. Sin tildes.
    [-k]: detiene el demonio si es que se esta ejecutando
	-h | -? | -help: ayuda sobre el script


#ACLARACIONES#
- El dia de la semana a excluir se puede ingresar en español o en ingles
"

uso="Uso del script: ./ejercicio3.sh <-p directorio> [-d diaDeLaSemana] [-k]"
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

    while true; do
        # Para cada archivo (con el formato correspondiente) dentro del directorio
        for archivo in $(find ./ -regextype posix-extended -regex '.*([0-9]{4})(0[1-9]|1[0-2])(0[1-9]|[1-2][0-9]|3[0-1])\_(2[0-3]|[01][0-9])([0-5][0-9])([0-5][0-9]).(jpg)$') # Iterar buscando archivos terminados en .jpg
        do
            # Extraer los primeros 8 nros del nombre del archivo
            date=$(echo "$archivo" | grep -oE '[0-9]{8}') 

            # Extraer los 6 nros finales del nombre del archivo
            hora=$(echo "$archivo" | grep -oE '[0-9]{6}.jpg') 

            # Determina el dia de la semana y lo convierto a minuscula
            nombre_dia=$(date -d $date +%A)
            nombre_dia=${nombre_dia,}

            # Formatea la fecha
            date="${date:0:4}-${date:4:2}-${date:6:2}" 

            # Formatea la hora
            hora="${hora:0:2}" 

            # Verifico si se quiere excluir un dia en base al parametro pasado
            if [[ ${2^^} != ${nombre_dia^^} ]]; then
                # Averiguo si la foto corresponde a una cena o a un almuerzo en base a la hora
                esCena $hora

                if [[ $? == 1 ]]; then
                    mv $archivo $(dirname "$archivo")/"$date cena del $nombre_dia.jpg"
                else
                    mv $archivo $(dirname "$archivo")/"$date almuerzo del $nombre_dia.jpg"
                fi
            fi
        done
    done
    echo "--------- Proceso finalizado ---------"
    exit 0;
}

# Funcion que detiene el demonio corriendo en segundo plano
stop() {
    # Obtengo el PID del proceso
    var=($(ps -ef | grep ${name} | awk ' {print $2}'))

    # Termino el proceso
    kill -9 "${var}"

    echo "Script detenido correctamente"
    exit 0;
}
# ---------------------------------- FIN FUNCIONES ----------------------------------

# ---------------------------------- VALIDACIONES ----------------------------------
# Obtengo el nombre del script
name="$0"

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

        # Verifico que el script solo pueda ser llamado una vez
        if [[ `ps -ef | grep ${name} | awk ' {print $2}' | wc -l` >3 ]]; then
            help "Solo puede ejecutar el proceso una vez"
        fi

        validarDirectorio "$1" ;
        dir="`obtenerPathAbsoluto "$1"`"
        validarParametrosOpcionales "$2" "$3"
        if [[ $? == 1 ]]; then

            # Mandamos toda salida de ejecucion a >/dev/null
            # Ejecutamos en segund plano con "&" 
            renombrarArchivos "$dir" >/dev/null &
            echo "Script corriendo en segundo plano"
        else
            renombrarArchivos "$dir" "$3" >/dev/null &
        fi
        exit 0;
        ;;
        -k) if [[ $# == 1 ]]; then
        
                # Verifico que el script se este ejecutando para poder detenerlo
                if [[ `ps -ef | grep ${name} | awk ' {print $2}' | wc -l` < 4 ]]; then
                    help "Para detener el demonio primero debe ejecutarlo"
                else
                    stop
                fi
            else
                help "Para detener el demonio solo debe ingresar el parametro -k"
            fi ;;
        * ) help "Parametros incorrectos" ; break ;;
    esac
done
# ---------------------------------- FIN PROGRAMA ----------------------------------

