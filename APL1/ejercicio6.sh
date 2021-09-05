#!/bin/bash

#ENCABEZADO

########################## FUNCIONES ##########################
validarNumeroReal() {
#reg="^-?(0|[1-9]\d*)(\.\d+)?$"
#reg2="^(-?[1-9]+\\d*([.]\\d+)?)$|^(-?0[.]\\d*[1-9]+)$|^0$"
#reg3="^([-+]?([0-9]+)(\.[0-9]+)?)$'"
#reg4="[^[+-]?\d+\.?\d*$]"
#regex="^[+-]?[0-9]*\.[0-9]+$"

regInt="^[+-]?[0-9]+$"
regFloat="^[+-]?[0-9]*\.[0-9]+$"
if [[ ! (($1 =~ $regInt || $1 =~ $regFloat) && ($2 =~ $regInt || $2 =~ $regFloat)) ]];
then
	echo "Error en los parametros. Los numeros ingresados deben ser reales. Para consultar la ayuda utilice -h, -? o -help"
	echo "$uso"
	exit 1
fi
}

validarParametros(){
echo $1 $2 $3
if [[ ! ($1 == "-n1" && $2 == "-n2" && ( $3 == "-suma" || $3 == "-resta" || $3 == "-division" || $3 == "-multiplicacion")) ]]
then
	echo "Error en los parametros. Para consultar la ayuda utilice -h, -? o -help"
	echo "$uso"
	exit 1
fi
}
suma() {
	echo "TORO"
	echo $n1
	echo $n2
	exit 1;
}
########################## FIN FUNCIONES ######################

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

validarNumeroReal $2 $4
validarParametros $1 $3 $5	
########################## FIN VALIDACIONES ######################

########################## PROGRAMA ##########################
while true; do
	case "$1" in
		-n1) n1=$2; shift ; shift ;;
		-n2) n2=$2; shift ; shift ;;
		-suma) suma ;;
		-resta) resta ;;
		-division) division ;;
		-multiplicacion) multiplicacion ;;
		* ) break ;;
	esac
done
########################## FIN PROGRAMA ######################
