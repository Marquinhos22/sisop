###################################
#                                 #
#        Trabajo Práctico 2       #
#          Ejercicio Nº 2         #
#            2_APL2.ps1           #
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
Renombra los archivos que poseen el siguiente formato: "yyyyMMdd_HHmmss.jpg" presentes en el directorio pasado por parametro.

.DESCRIPTION
Este script permite renombrar los archivos que poseen el siguiente formato: "yyyyMMdd_HHmmss.jpg" presentes en el directorio pasado por parametro.
El formato de salida será el siguiente: “dd-MM-yyyy (almuerzo|cena) del NombreDia.jpg”.

.PARAMETER Directorio
Directorio donde se encuentran las imágenes a renombrar.

.PARAMETER Dia
(Opcional) Es el nombre de un día para el cual no se quieren renombrar los archivos.
Los valores posibles para este parámetro son los nombres de los días de la semana (sin tildes).
       
.EXAMPLE
./2_APL2.ps1 -Directorio ".\Pruebas\Lote-Ej2"

.EXAMPLE
./2_APL2.ps1 -Directorio ".\Pruebas\Lote-Ej2" -Dia miercoles 
#>

# ---------------------------------- FIN AYUDA ---------------------------------- #

# ---------------------------------- VALIDACIONES ---------------------------------- #
[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({
        if( -Not ($_ | Test-Path) ){
            throw "El directorio ingresado no existe"
        }
        return $true
    })]
    #[ValidateScript( { Test-Path -PathType Container $_ } )]
    [String] $Directorio,
    
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("lunes", "martes", "miercoles", "jueves", "vienes", "sabado", "domingo",
    #ErrorMessage="{0} no es un dia de la semana. Por favor ingrese el parametro correctamente",
    IgnoreCase=$true
    )]
    [String] $Dia
)
# ---------------------------------- FIN VALIDACIONES ---------------------------------- #

# ---------------------------------- FUNCIONES ---------------------------------- #
function obtenerDia {
    Param (
        [String] $d
    )
    $dEspanol = "lunes", "martes", "miércoles", "jueves", "vienes", "sábado", "domingo"
    $dIngles = "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
    $cont = 0
    foreach ($cambio in $dIngles) {
        if ($d -eq $cambio) {
            $d = $dEspanol[$cont - 1]
        }
        $cont++;
    }
    return $d
}

function obtenerHora {
    Param (
        [string] $hora
    )
    if ($hora -ge 190000) {
        return "cena"
    }
    else {
        return "almuerzo"
    }
}
# ---------------------------------- FIN ---------------------------------- #

# ---------------------------------- MAIN ---------------------------------- #
$fotos = Get-ChildItem -Path $Directorio -Recurse | Where-Object { $_.Name -match '.*([0-9]{4})(0[1-9]|1[0-2])(0[1-9]|[1-2][0-9]|3[0-1])_(2[0-3]|[01][0-9])([0-5][0-9])([0-5][0-9]).(jpg)$' }

foreach ($foto in $fotos) {
    $fechaHora = ($foto.Name).Split("_")
    $d = [datetime]::ParseExact($fechaHora[0], "yyyyMMdd", $null).DayofWeek
    $d = obtenerDia($d)
    $hora = obtenerHora($fechaHora[1])
    if ($Dia.ToUpper() -ne $d.Replace("á", "a").Replace("é", "e").ToUpper()) {
        $calendario = $fechaHora[0] -replace '(\d{4})(\d{2})(\d{2})', '$3-$2-$1'
        Rename-Item (Get-ChildItem -Path $Directorio\"$foto" -Recurse) "$calendario $hora del $d.jpg"
    }
}
# ---------------------------------- FIN MAIN ---------------------------------- #
