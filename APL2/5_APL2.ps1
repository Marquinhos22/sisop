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
Ayuda correspondiente al script 5_APL2.ps1
Este script permite generar archivos .zip en base a logs viejos almacenados en rutas provistas en un archivo de configuracion.
Una vez comprimidos, los archivos se deben eliminar para ahorrar espacio en el disco del servidor. 
Se considera antiguo a un archivo de log que no fue creado el día en el que se corre el script(24 hs).

.DESCRIPTION
- El archivo de configuracion debe tener la siguiente estructura:
	- En la primera linea la carpeta de destino de los archivos comprimidos
	- A partir de la segunda linea, las rutas donde se encuentran las carpetas de logs a analizar.
.PARAMETER Directorio
Directorio donde se encuentran el archivo de configuracion.
    
.EXAMPLE
./2_APL2.ps1 -Directorio ".<archivoDeConfiguracion.txt>"

#>

# ---------------------------------- FIN AYUDA ---------------------------------- #

# ------------ Validaciones ---------------- #
Param (
[Parameter(Mandatory=$true, Position = 1, ParameterSetName="Directorio")] 
[ValidateScript({
    if( -Not ("$_" | Test-Path) ){
        throw "Archivo no existe"
    }
    return $true
})]
[System.String] $Directorio
)
#Convert-Path .

#$Ruta=Join-Path -Path $(Get-Location) -ChildPath $Directorio
#salida----->C:\Users\fernando\Desktop\APL 2 ejercicio 5\.\tmp\viejos_logs
#$locacion=Get-Location
#salida----->C:\Users\fernando\Desktop\APL 2 ejercicio 5\.
$FILE = Get-Content "$Directorio"# File sera el contenedor del contenido(paths)
$FileAbsoluto = New-Object -TypeName "System.Collections.ArrayList" 
$FileZip = New-Object -TypeName "System.Collections.ArrayList" 
foreach ($LINE in $FILE) # Verificar las rutas(paths) obtenidas
{
        #Join-Path -Path $(Get-Location) -ChildPath $LINE
        #C:\Users\fernando\Desktop\APL 2 ejercicio 5\.\tmp\servicios\ubicaciones\temporales
       
        #write-Host "El directorios $([io.path]::GetFullPath($LINE)) no existe"
        #salida---->El directorios C:\Users\fernando\tmp\servicios\busqueda\logs no existe
        if( -Not (Resolve-Path $LINE) ){
        Write-error "El directorio obtenido del archivo de configuracion no existe"
        return false;
        }
        else{#Si exite, tratar de generar los zip namebase
        #[io.path]::GetFileName( [io.path]::GetDirectoryName($LINE))
        $date=get-date
        #yyyyMMdd_HHmmss
        #$date.ToString("yyyyMMdd_HHmmss")
        $FileZip.Add("Log_$([io.path]::GetFileName( [io.path]::GetDirectoryName($LINE)))_$($date.ToString("yyyyMMdd_HHmmss")).zip")
        #[io.path]::GetDirectoryName($LINE)
        #$LINE | Select-Object -Property @{name='NAME';expression={$LINE}}
        } 
}


#$Global:dir="" 
#$Global:=".zip" 
# ------------Fin de Validaciones --------------------------- #

#---------------------Proceso principal-----------------------#
foreach ($LINE in $FileZip) # Verificar las rutas(paths) obtenidas
{
Write-output $LINE
}
foreach ($LINE in $FILE) # Verificar las rutas(paths) obtenidas
{
$date=get-date
$($date.ToString("dd/MM/yy"))
write-Host $LINE
$directoriosFiltradosAntiguos= get-ChildItem $LINE| where-object {$_.lastwritetime -lt [datetime]::parse($($date.ToString("dd/MM/yy")))}
write-Host $directoriosFiltradosAntiguos
}

#------------------------Prototipo de zippeo-----------------------
#Add-Type -Assembly System.IO.Compression.FileSystem
#$compressionLevel = [System.IO.Compression.CompressionLevel]::Fastest
#[System.IO.Compression.ZipFile]::CreateFromDirectory("$dirPapelera", "$dirPapeleraCompr", $compressionLevel, $false)
#No se usa Compress-Archive -CompressionLevel Fastest -Path "$dirPapelera" -DestinationPath "$dirPapeleraCompr" | Out-Null
#remove-item -Force -Recurse $Global:dirPapelera | Out-Null
