#!/bin/bash

#ENCABEZADO

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
validarNumeroReal() {
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

validarParametros() {
#if [[ ! ($1 == "-n1" && $2 == "-n2" && ( $3 == "-suma" || $3 == "-resta" || $3 == "-division" || $3 == "-multiplicacion")) ]]
#then
#	echo "Error en los parametros. Para consultar la ayuda utilice -h, -? o -help"
#	echo "$uso"
#	exit 1;
#fi

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
	echo "Se restaran $1 y $2"
	echo "scale=4; ($1)-($2)" | bc
	exit 1;
}

multiplicacion() {
	echo "Se multiplicaran $1 y $2"
	echo "scale=4; ($1)*($2)" | bc
	exit 1;
}

division() {
	echo $2
	if [[ `bc <<< "$2==0"` ]]; then
		echo "No se puede dividir por 0"
		exit 1;
	fi

	echo "Se hara el cociente entre $1 y $2"
	echo "scale=4; ($1)/($2)" | bc
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

#validarParametros $1 $3 $5	
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
