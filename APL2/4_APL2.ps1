	###################################
	#                                 #
	#        Trabajo Práctico 2       #
	#          Ejercicio Nº 4         #
	#            4_APL2.ps1           #
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
Este script consolida y procesa los archivos .csv de ventas de sucursales en un unico archivo .json

.DESCRIPTION
Este script consolida y procesa los archivos .csv de ventas de sucursales en un unico archivo .json
    - El archivo de salida .json estara ordenado alfabeticamente
    - Se informaran las sucursales que no contengan datos de entrada

.INPUTS
1. -directorio: Directorio donde se encuentran los archivos CSV a procesar. Se analizaran también subdirectorios.
2. -out: Directorio donde se desea guardar el archivo resultante 'salida.json'
3. -excluir: Nombre de archivo de sucursal a excluir.

.PARAMETER Directorio
Directorio donde se encuentran los archivos CSV a procesar. Se analizaran también subdirectorios.

.PARAMETER Out
Directorio donde se desea guardar el archivo resultante 'salida.json'

.PARAMETER Excluir
(Opcional) Nombre de archivo de sucursal a excluir.

.EXAMPLE
./4_APL2.ps1 <-directorio directorioEntrada> [-excluir sucursal] <-out directorioSalida>

.EXAMPLE
./4_APL2.ps1 -directorio 'lotePrueba' -excluir 'Moron' -out 'Salida'

.EXAMPLE
./4_APL2.ps1 -directorio 'PathsCSV' -out /home/usuario/dirSalida

.OUTPUTS
Genera un archivo Json con el acta generada en el path indicado en el parametro -out.
#> 

# ---------------------------------- FIN AYUDA ---------------------------------- #

# ---------------------------------- VALIDACIONES ---------------------------------- #
Param
(
    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [System.IO.FileInfo]$directorio,
    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [System.IO.FileInfo]$out,
    [parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$excluir
)

# Validacion de path de entrada
if (!(Test-Path -Path $directorio -IsValid)) {
    Write-Error -Message "El directorio '$directorio' no existe."
    exit -1
}

#Validacion de path de salida
if (!(Test-Path -Path $out -IsValid)) {
    Write-Error "La sintaxis del directorio '$out' no es correcta."
    exit -1
}

# Validacion que la entrada y salida no sean los mismos directorios
$pathSalida = Resolve-path $out
$pathEntrada = Resolve-path $directorio

if (!(compare-object -Referenceobject  $pathSalida -DifferenceObject $pathEntrada)) {
    Write-Error "Los directorios -directorios y -out no pueden ser los mismos."
    exit -1
}
# ---------------------------------- FIN VALIDACIONES ---------------------------------- #

# ---------------------------------- MAIN ---------------------------------- #
$productosSucursales = @{}
$sucursalesVacias = [System.Collections.ArrayList]::new()

# Recorro el directorio de entrada (recursivamente) filtrando por archivos.csv y excluyendo la sucursal -excluir  
Get-ChildItem $pathEntrada -Recurse -Filter *.csv -Exclude $excluir'.csv'  | Foreach-Object {

    #Si el csv esta vacio o solo tiene cabecera, guardo nombre de sucursal
    if ( $_.Length -eq 0 -or $_.Length -eq 1 ) {
        [void]$sucursalesVacias.Add($_.BaseName)
    }
    else {
        # Recorro archivo .csv
        Import-Csv $_.fullname -Delimiter ',' | ForEach-Object {
            $producto = $_.NombreProducto
            $importe = [int]$_.ImporteRecaudado
            
            # Si el producto ya se encuentra en el hashtable, sumo su importe, sino agrego producto e importe
            if ($productosSucursales.ContainsKey($producto)) {
                $productosSucursales[$producto] = $productosSucursales[$producto] + $importe 
            }
            else {
                # El nombre de producto lo tomo con la norma: primera letra mayuscula y despues minusculas
                [void]$productosSucursales.Add($producto.substring(0,1).toupper()+$producto.substring(1).tolower(),$importe)
            }  
        }
    }    
} 

# Creo el archivo salida.json ordenado por nombre de productos en la carpeta de salida
$productosSucursales | Sort-Object |ConvertTo-Json -Compress > $pathSalida'/salida.json'

# Si se encontraron archivos vacios muestro el listado 
if ( $sucursalesVacias.Count -ne 0 ){

    Write-Output "Las siguientes sucursales tuvieron problemas y estan vacias:"
    $sucursalesVacias | Format-Table | Sort-Object
}
# ---------------------------------- FIN MAIN ---------------------------------- #