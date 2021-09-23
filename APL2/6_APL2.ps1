	###################################
	#                                 #
	#        Trabajo Práctico 2       #
	#          Ejercicio Nº 6         #
	#            6_APL2.ps1           #
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
# ---------------------------------- AYUDA ---------------------------------- #

<#
.SYNOPSIS
Calculadora simple con 2 numeros reales.

.DESCRIPTION
Este script permite, dados 2 numeros reales, realizar operaciones matematicas basicas sobre ellos.

.PARAMETER n1
Indica el primer operando de la operacion.

.PARAMETER n2
Indica el segundo operando de la operacion.

.PARAMETER suma
Indica que se quiere realizar la operacion de suma.     

.PARAMETER resta
Indica que se quiere realizar la operacion de resta.  

.PARAMETER multiplicacion
Indica que se quiere realizar la operacion de multiplicacion.   

.PARAMETER division
Indica que se quiere realizar la operacion de division.
El parametro "-n2" debe ser distinto de 0.   

.EXAMPLE
./6_APL2.ps1 -n1 2 -n2 2 -suma

.EXAMPLE
./6_APL2.ps1 -n1 2.5 -n2 -2.3 -resta 

.EXAMPLE
./6_APL2.ps1 -n1 10 -n2 -10 -multiplicacion 

.EXAMPLE
./6_APL2.ps1 -n1 10 -n2 -0.2 -division 
#>

# ---------------------------------- FIN AYUDA ---------------------------------- #

# ---------------------------------- VALIDACIONES ---------------------------------- #
Param (
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
[Double] $n1,

[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
[Double] $n2,

[Parameter(Mandatory=$true, ParameterSetName="suma")] 
[switch] $suma,
[Parameter(Mandatory=$true, ParameterSetName="resta")] 
[switch] $resta,
[Parameter(Mandatory=$true, ParameterSetName="multiplicacion")] 
[switch] $multiplicacion,
[Parameter(Mandatory=$true, ParameterSetName="division")] 
[switch] $division
)
# ---------------------------------- FIN VALIDACIONES ---------------------------------- #

# ---------------------------------- FUNCIONES ---------------------------------- #
# Funcion que realiza la suma de operandos
function suma {
    $res = $n1 + $n2
    Write-Output "$n1 + $n2 = $res"
}

# Funcion que realiza la resta de operandos
function resta {
    $res = $n1 - $n2
    Write-Output "$n1 - $n2 = $res"
}

# Funcion que realiza la multiplicacion de operandos
function multiplicacion {
    $res = $n1 * $n2
    Write-Output "$n1 * $n2 = $res"
}

# Funcion que realiza la division de operandos
function division {
    if($n2 -eq 0) {
        Write-Error "No se puede dividir por 0"
    }
    $res = $n1 / $n2
    Write-Output "$n1 / $n2 = $res"
}
# ---------------------------------- FIN FUNCIONES ---------------------------------- #

# ---------------------------------- MAIN ---------------------------------- #
if($suma){
    suma
}

if($resta){
    resta
}

if($multiplicacion){
    multiplicacion
}

if($division){
    division
}
# ---------------------------------- FIN MAIN ---------------------------------- #
