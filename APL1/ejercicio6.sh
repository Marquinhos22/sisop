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
	# Ramos, Marcos Gerardo   	      #
	# DNI: 1.111.111                  #
	#                                 #
	# Martes, Lucas             	  #
	# DNI: 39.348.436                 #
	#                                 #
	# Rius Conde, Lucio        	  	  #
	# DNI: 41.779.534 		  		  #
	# 				  				  #
	# Sullca, Fernando Willian        #
	# DNI: 37.841.788		  	      #
	#                                 #
	# 	      1º Presentación     	  #
	#                                 #
	###################################

################################## AYUDA ##################################
ayuda="
Ayuda correspondiente al script ejercicio6.sh

#OBJETIVO PRINCIPAL#

Este script permite, dados 2 numeros reales, realizar operaciones matematicas basicas sobre ellos

#USO Y PARAMETROS#

Uso: ./ejercicio6.sh < -n1 nnnn -n2 nnnn -suma | -resta | -multiplicacion | -division > 
Donde:
[-n1 nnnn]: primer operando.
[-n2 nnnn]: segundo operando.
[-suma | -resta | -multiplicacion | -division]: tipo de operacion matematica a realizar

#ACLARACIONES#

- Todos los parametros del script son obligatorios.
- Solo se puede realizar una operacion matematica a la vez por par de operandos.
- Los operandos pueden ser cualquier numero real.
"

uso="Uso del script: ./ejercicio6.sh < -n1 nnnn -n2 nnnn -suma | -resta | -multiplicacion | -division >"
################################## FIN AYUDA ##################################

################################## FUNCIONES ##################################
# Aquí se verifica que los parametros correspondientes a los operandos de las operaciones sean numeros reales
validarNumeroReal() {	
regInt="^[+-]?[0-9]+$" # Expresion REGEX que valida enteros
regFloat="^[+-]?[0-9]*\.[0-9]+$" # Expresion REGEX que valida flotantes

# Se verifica que el operando matchee ambos REGEX
if [[ ! ($1 =~ $regInt || $1 =~ $regFloat) ]];
then
	echo "Error en los parametros. Los numeros ingresados deben ser reales. Para consultar la ayuda utilice -h, -? o -help"
	echo "$uso"
	exit 1;
fi

}

# Esta funcion es llamada cuando se detecta que se ha ingresado un parametro eligiendo la operacion matematica a realizar
# Al verificar que los operandos no esten vacios, nos aseguramos que sean los primeros parametros en pasarse.
validarParametros() { 
if [[ ( -z "$1" || -z "$2" ) ]]
then
	echo "Error en los parametros. Por favor ingrese la operacion luego de los operandos. Para consultar la ayuda utilice -h, -? o -help"
	echo "$uso"
	exit 1;
fi
}

# Aqui se realiza la suma de los operandos
suma() { 
	res=`echo "scale=4; ($1)+($2)" | bc`
	echo "$1 + $2 = $res" 
	exit 1;
}

# Aqui se realiza la resta de los operandos
resta() { 
	res=`echo "scale=4; ($1)-($2)" | bc`
	echo "$1 - $2 = $res"
	exit 1;
}

# Aqui se realiza la multiplicacion de los operandos
multiplicacion() { 
	res=`echo "scale=4; ($1)*($2)" | bc`
	echo "$1 * $2 = $res"
	exit 1;
}

# Aqui se realiza la division de los operandos, verificando que el segundo operando sea distinto de 0
division() {
	if (( $(echo "$2 == 0" | bc -l) )); then
		echo "No se puede dividir por 0"
		exit 1;
	fi

	res=`echo "scale=4; ($1)/($2)" | bc`
	echo "$1 / $2 = $res"
	exit 1;
}
################################## FIN FUNCIONES ##################################

################################## VALIDACIONES ##################################
# Si no se pasaron parametros al script se informa error
if [[ $# == 0 ]]
then
	echo "El script requiere parametros para funcionar. Para consultar la ayuda utilice -h, -? o -help"
	echo "$uso"
	exit 1
fi

# Si hay un solo parametro se verifica si es la ayuda o no
if [[ $# == 1 ]] 
then
	if [[ $1 == "-h" || $1 == "-?" || $1 == "-help" ]]
	then
		echo "$ayuda"
		exit 1;
	fi
fi

# Si hay mas de cinco parametros (cantidad pedida) se informa error
if [[ $# > 5 ]]
then
	echo "Error en la cantidad de parametros. Para consultar la ayuda utilice -h, -? o -help"
	echo "$uso"
	exit 1;
fi
################################## FIN VALIDACIONES ##################################

################################## PROGRAMA ##################################
while true; do
	case "$1" in
		-n1) validarNumeroReal $2 ; n1=$2 ; shift ; shift ;; # Guardamos el operando en la variable correspondiente
		-n2) validarNumeroReal $2 ; n2=$2 ; shift ; shift ;; # Guardamos el operando en la variable correspondiente
		-suma) validarParametros $n1 $n2; suma $n1 $n2 ;;
		-resta) validarParametros $n1 $n2; resta $n1 $n2 ;;
		-division) validarParametros $n1 $n2; division $n1 $n2 ;;
		-multiplicacion) validarParametros $n1 $n2; multiplicacion $n1 $n2 ;;
		* ) echo "$uso" ; exit 1; break ;;
	esac
done
################################## FIN PROGRAMA ##################################
