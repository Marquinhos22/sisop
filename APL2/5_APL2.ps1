    ###################################
    #                                 #
    #        Trabajo Práctico 2       #
    #          Ejercicio Nº 5         #
    #            5_APL2.ps1           #
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
Este script permite generar archivos .zip en base a logs viejos almacenados en rutas provistas en un archivo de configuracion.

.DESCRIPTION
Este script permite generar archivos .zip en base a logs viejos almacenados en rutas provistas en un archivo de configuracion.
Una vez comprimidos, los archivos se eliminan para ahorrar espacio en el disco del servidor. 
Se considera antiguo a un archivo de log que no fue creado el día en el que se corre el script (24 hs).

- El archivo de configuracion debe tener la siguiente estructura:
	- En la primera linea la carpeta de destino de los archivos comprimidos
	- A partir de la segunda linea, las rutas donde se encuentran las carpetas de logs a analizar.

.PARAMETER Directorio
Directorio donde se encuentran el archivo de configuracion.
    
.EXAMPLE
./5_APL2.ps1 -Directorio ".<archivoDeConfiguracion.txt>"
#>

# ---------------------------------- FIN AYUDA ---------------------------------- #

# ---------------------------------- VALIDACIONES ---------------------------------- #
Param (
    [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "Directorio")] 
    [ValidateScript({
            if ( -Not ("$_" | Test-Path) ) {
                throw "El archivo de configuracion pasado por parametros no existe"
            }
            return $true
        })]
    [System.String] $Directorio
)

# File sera el contenedor del contenido del archivo de configuracion (paths)
$FILE = Get-Content "$Directorio"
$FileAbsoluto = New-Object -TypeName "System.Collections.ArrayList" 
$FileZip = New-Object -TypeName "System.Collections.ArrayList" 
$esDirDest = $true

# Verificar las rutas (paths) obtenidas
foreach ($LINE in $FILE) {

    if ( -Not (Resolve-Path $LINE) ) {
        Write-error "El directorio $($LINE) obtenido del archivo de configuracion no existe"
        exit 1
    }
    else {
        # Si exite el path, tratar de generar los zip namebase
        # [void] --> para evitar que ArrayList.Add devuelva el indice del nuevo elemento agregado
        [void]$FileAbsoluto.Add($(Resolve-Path $LINE))
        if ( -Not ($esDirDest) ) {
            $date = get-date
            [void]$FileZip.Add("logs_$([io.path]::GetFileName( [io.path]::GetDirectoryName($LINE)))_$($date.ToString("yyyyMMdd_HHmmss")).zip")
        }
    } 
    $esDirDest = $false
}

$SubdirDest = $FileAbsoluto[0] # Ruta destino
$SubdirZIP = $FileAbsoluto[1..($FileAbsoluto.count - 1)] # Ruta origen donde estan los logs
# ---------------------------------- FIN VALIDACIONES ---------------------------------- #

# ---------------------------------- MAIN ---------------------------------- #
$control = 0;

# Verificar las rutas (paths) obtenidas y filtrado de archivo por cada carpeta
foreach ($LINE in $SubdirZIP) {
    # Obtengo la fecha actual
    $date = get-date

    $destino = Join-Path -Path $SubdirDest -ChildPath $($FileZip[$control])
    write-Host  $destino

    # Genero el .zip
    get-ChildItem $LINE | where-object { $_.lastwritetime -lt [datetime]::parse($($date.ToString("dd/MM/yy"))) } | Compress-Archive -DestinationPath  "$destino"

    # Elimino los archivos zipeados
    get-ChildItem $LINE | where-object { $_.lastwritetime -lt [datetime]::parse($($date.ToString("dd/MM/yy"))) } | remove-item -Force | Out-Null

    $control = $control + 1
}
# ---------------------------------- FIN MAIN ---------------------------------- #

