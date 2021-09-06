#!/bin/bash

	###################################
	#                                 #
	#        Trabajo Práctico 1       #
	#          Ejercicio Nº 6         #
	#           ejercicio6.sh         #
	#                                 #
	# Cammarano, Santiago             #
	# DNI: 41.582.407                 #
	#                                 #
	# Ramos, Marcos Gerardo   	  #
	# DNI: 1.111.111                #
	#                                 #
	# Martes, Lucas             	  #
	# DNI: 39.348.436                 #
	#                                 #
	# Rius Conde, Lucio        	  #
	# DNI: 41.779.534 		  #
	# 				  #
	# Sullca, Fernando Willian        #
	# DNI: 37.841.788		  #
	#                                 #
	# 	      1º Presentación     #
	#                                 #
	###################################

# El objetivo de este script es el de proveer al usuario con una calculadora capaz de realizar las operaciones matemáticas simples
# Ejemplo: bash ejercicio6.sh -n1 2 -n2 1 -division	# En este caso se realizará 2/1 y se mostrará "1" como resultado

########################## AYUDA ##########################
ayuda="
Ayuda correspondiente al script ejercicio6.sh
#OBJETIVO PRINCIPAL#
Este script permite, dados 2 numeros reales, realizar operaciones matematicas basicas sobre ellos

#USO Y PARAMETROS#
Uso: ./ejercicio6.sh <-n1 nnnn -n2 nnnn -suma | -resta | -multiplicacion | -division > 
Donde:
[-n1 nnnn]: primer operando.
[-n2 nnnn]: segundo operando.
[-suma | -resta | -multiplicacion | -division]: tipo de operacion matematica a realizar

#ACLARACIONES#
- Tanto -n1 nnnn como -n2 nnnn son parametros obligatorios.
- Solo se puede realizar una operacion matematica a la vez por par de operandos.
- Los operandos pueden ser cualquier numero real
"

uso="Uso del script: ./ejercicio6.sh <-n1 nnnn -n2 nnnn -suma | -resta | -multiplicacion | -division > "
########################## FIN AYUDA ######################

########################## FUNCIONES ##########################
validarNumeroReal() {	#Aquí se verifica que los parametros correspondientes a los operandos de las operaciones sean numeros reales.
#reg="^-?(0|[1-9]\d*)(\.\d+)?$"
#reg2="^(-?[1-9]+\\d*([.]\\d+)?)$|^(-?0[.]\\d*[1-9]+)$|^0$"
#reg3="^([-+]?([0-9]+)(\.[0-9]+)?)$'"
#reg4="[^[+-]?\d+\.?\d*$]"
#regex="^[+-]?[0-9]*\.[0-9]+$"

regInt="^[+-]?[0-9]+$"
regFloat="^[+-]?[0-9]*\.[0-9]+$"
if [[ ! ($1 =~ $regInt || $1 =~ $regFloat) ]];
then
	echo "Error en los parametros. Los numeros ingresados deben ser reales. Para consultar la ayuda utilice -h, -? o -help"
	echo "$uso"
	exit 1;
fi

}

validarParametros() {	#Aquí se verifica que primero se pasen los operandos y luego el tipo de operacion a realizar sobre ellos.
if [[ ( -z "$1" || -z "$2" ) ]]
then
	echo "Error en los parametros. Por favor ingrese la operacion luego de los operandos. Para consultar la ayuda utilice -h, -? o -help"
	echo "$uso"
	exit 1;
fi
}

suma() {
	res=`echo "scale=4; ($1)+($2)" | bc`
	echo "$1 + $2 = $res" 
	exit 1;
}

resta() {
	res=`echo "scale=4; ($1)-($2)" | bc`
	echo "$1 - $2 = $res"
	exit 1;
}

multiplicacion() {
	res=`echo "scale=4; ($1)*($2)" | bc`
	echo "$1 * $2 = $res"
	exit 1;
}

division() {
	if (( $(echo "$2 == 0" | bc -l) )); then
		echo "No se puede dividir por 0"
		exit 1;
	fi

	res=`echo "scale=4; ($1)/($2)" | bc`
	echo "$1 / $2 = $res"
	exit 1;
}
########################## FIN FUNCIONES ######################


########################## VALIDACIONES ##########################
if [[ $# == 0 ]]
then
	echo "El script requiere parametros para funcionar. Para consultar la ayuda utilice -h, -? o -help"
	echo "$uso"
	exit 1
fi

if [[ $# == 1 || $# > 5 ]]
then
	if [[ $1 == "-h" || $1 == "-?" || $1 == "-help" ]]
	then
		echo "$ayuda"
		exit 1
	else
		echo "Error en la cantidad de parametros. Para consultar la ayuda utilice -h, -? o -help"
		echo "$uso"
		exit 1
	fi
fi
########################## FIN VALIDACIONES ######################

########################## PROGRAMA ##########################
while true; do
	case "$1" in
		-n1) validarNumeroReal $2 ; n1=$2 ; shift ; shift ;;
		-n2) validarNumeroReal $2 ; n2=$2 ; shift ; shift ;;
		-suma) validarParametros $n1 $n2; suma $n1 $n2 ;; 
		-resta) validarParametros $n1 $n2; resta $n1 $n2 ;;
		-division) validarParametros $n1 $n2; division $n1 $n2 ;;
		-multiplicacion) validarParametros $n1 $n2; multiplicacion $n1 $n2 ;;
		* ) echo "$uso" ; exit 1; break ;;
	esac
done
########################## FIN PROGRAMA ######################
