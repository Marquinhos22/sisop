    ###################################
    #                                 #
    #        Trabajo Práctico 2       #
    #          Ejercicio Nº 3         #
    #            3_APL2.ps1           #
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
Renombra los archivos que poseen el siguiente formato: "yyyyMMdd_HHmmss.jpg" presentes en el directorio pasado por parametro, realizando un monitoreo del mismo.

.DESCRIPTION
Este script permite renombrar los archivos que poseen el siguiente formato: "yyyyMMdd_HHmmss.jpg" presentes en el directorio pasado por parametro.
El formato de salida será el siguiente: “dd-MM-yyyy (almuerzo|cena) del NombreDia.jpg”.
Para realizar esto, monitorea en segundo plano el directorio pasado por parametros en busca de archivos con el formato correspondiente.
El script admite un parametro obligatorio que es la ruta del directorio y un parametro opcional que es el nombre de un dia para el cual no se quieren renombrar los archivos.
Ademas, el script admite un parametro opcional para detener el mismo si es que se esta ejecutando.

.PARAMETER Directorio
Directorio donde se encuentran las imágenes a renombrar.

.PARAMETER Dia
(Opcional) Es el nombre de un día para el cual no se quieren renombrar los archivos.
Los valores posibles para este parámetro son los nombres de los días de la semana en mayúsculas o minúsculas (sin tildes).

.PARAMETER K
(Opcional) Detiene el monitoreo.
       
.EXAMPLE
./3_APL2.ps1 -Directorio ".\Pruebas\Lote-Ej3"

.EXAMPLE
./3_APL2.ps1 -Directorio ".\Pruebas\Lote-Ej3" -Dia miercoles

.EXAMPLE
./3_APL2.ps1 -k
#>

# ---------------------------------- FIN AYUDA ---------------------------------- #

# ---------------------------------- VALIDACIONES ---------------------------------- #
[CmdletBinding()]
Param (
    [parameter(Mandatory = $false, ParameterSetName = "detener")]
    [Switch] $k,
    
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({
            if ( -Not ($_ | Test-Path) ) {
                throw "El directorio ingresado no existe"
            }
            return $true
        })]
    [String] $Directorio,
    
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("lunes", "martes", "miercoles", "jueves", "vienes", "sabado", "domingo",
        IgnoreCase = $true
    )]
    [String] $Dia
)

# Verificacion de que el parametro de monitoreo se pase sin ningun otro al script
# Ademas se valida de que se hayan ingresado los parametros correspondientes si no se quiere detener el script
if ($PSBoundParameters.ContainsKey('k')) {
    if ($PSBoundParameters.ContainsKey('directorio') -or $PSBoundParameters.ContainsKey('dia')){
        Write-Error "Si desea detener el script, solo debe ingresar el parametro correspondiente"
        exit 1
    }
} elseif (!$PSBoundParameters.ContainsKey('directorio')) {
    Write-Error "El parametro Directorio es obligatorio"
}
# ---------------------------------- FIN VALIDACIONES ---------------------------------- #

# ---------------------------------- MISCELLANEOUS ---------------------------------- #
# Accion a realizar por el monitor
$renombrarArchivos = {
    if ($_) {
        $fileActual = $_ 
    }
    else {
        $details = $event.SourceEventArgs
        $Name = $details.Name
        $fileActual = $Name
    }
    $details = $event.SourceEventArgs
    $Name = Split-Path $fileActual -Leaf

    if ($Name -match '.*([0-9]{4})(0[1-9]|1[0-2])(0[1-9]|[1-2][0-9]|3[0-1])_(2[0-3]|[01][0-9])([0-5][0-9])([0-5][0-9]).(jpg)$') {

        $fechaHora = ($Name).Split("_")

        $d = [datetime]::ParseExact($fechaHora[0], "yyyyMMdd", $null).DayofWeek
        $d = global:obtenerDia($d)

        $hora = global:obtenerHora($fechaHora[1])

        if ($Dia.ToUpper() -ne $d.Replace("á", "a").Replace("é", "e").ToUpper()) {
            $calendario = $fechaHora[0] -replace '(\d{4})(\d{2})(\d{2})', '$3-$2-$1'
            Rename-Item (Get-ChildItem -Path $Directorio\"$Name" -Recurse) "$calendario $hora del $d.jpg"
        }
    }
}

# Setea que todos los errores paren la ejecución del script. Esto permite hacer un try catch en partes críticas del script
$erroractionPreference = "stop"

# Declaramos las variables de los parametros ingresados como globales para su posterior acceso
$Global:Directorio = $Directorio
$Global:Dia = $Dia
# ---------------------------------- FIN MISCELLANEOUS ---------------------------------- #

# ---------------------------------- FUNCIONES ---------------------------------- #
# Funciones globales para poder accederlas desde la accion que realiza el monitor
function global:obtenerDia {
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

function global:obtenerHora {
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

function detener {
    # Busco los eventos creados e identificados (si se ha comenzado un monitoreo)
    try {
        Get-EventSubscriber -SourceIdentifier "watch created" | Unregister-Event
        Get-EventSubscriber -SourceIdentifier "watch renamed" | Unregister-Event
    }
    catch {
        Write-Warning "No se encontro monitoreo en funcionamiento"
        exit 1
    }

    # Trato de eliminar la ejecucion del monitoreo en segundo plano
    try {
        Remove-Job -Force -Name "watch created"
        Remove-Job -Force -Name "watch renamed"
    }
    catch {
        Write-Warning "No se encontro monitoreo en funcionamiento"
        exit 1
    }

    Write-Warning "Monitoreo detenido con exito"
    exit 0
}
# ---------------------------------- FIN FUNCIONES---------------------------------- #

# ---------------------------------- MAIN ---------------------------------- #
if ($k) {
    detener
}

# Al ser una mejora del ejercicio2, el script sigue renombrando los archivos antes de ponerse en modo monitoreo
Get-ChildItem -Path $Directorio -Recurse | Where-Object { $_.Name -match '.*([0-9]{4})(0[1-9]|1[0-2])(0[1-9]|[1-2][0-9]|3[0-1])_(2[0-3]|[01][0-9])([0-5][0-9])([0-5][0-9]).(jpg)$' } | ForEach-Object { & $renombrarArchivos }

# MONITOREO #

# Especifica la propiedad que se desea monitorear
$AttributeFilter = [IO.NotifyFilters]::FileName, [IO.NotifyFilters]::LastWrite

# Establece un objeto para monitorear los archivos del path Directorio
$monitor = New-Object -TypeName System.IO.FileSystemWatcher -Property @{
    Path                  = "$Directorio"
    Filter                = '*.jpg'
    IncludeSubdirectories = $true
    NotifyFilter          = $AttributeFilter
}

try {
    # Registramos los event handlers (sólo nos interesa cuando se crean y renombran archivos)
    Register-ObjectEvent -InputObject $monitor -EventName Created -Action $renombrarArchivos -SourceIdentifier "watch created" | Out-Null
    Register-ObjectEvent -InputObject $monitor -EventName Renamed -Action $renombrarArchivos -SourceIdentifier "watch renamed" | Out-Null
}
catch {
    Write-Warning "Ya hay un monitoreo en funcionamiento"
    exit 1
}

# Comienza el monitoreo
$monitor.EnableRaisingEvents = $true
Write-Host "Monitoreando $Directorio" -ForegroundColor Green
# ---------------------------------- FIN MAIN ---------------------------------- #
