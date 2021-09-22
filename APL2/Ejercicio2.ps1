Param (
[Parameter(Mandatory=$true)]
   [string] $Directorio,
   [string] $Dia
)
function obtenerDia{
    Param (
    [string] $d
    )
    $dEspanol="lunes","martes","miércoles","jueves","vienes","sábado","domingo"
    $dIngles= "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
    $cont = 0
    foreach ($cambio in $dIngles) 
    {
        if($d -eq $cambio)
        {
            $d=$dEspanol[$cont-1]
        }
        $cont++;
    }
    return $d
}

function obtenerHora{
    Param (
    [string] $hora
    )
    if($hora -ge 190000)
    {
        return "cena"
    }
    else 
    {
        return "almuerzo"
    }
}


$fotos=Get-ChildItem -Path $Directorio -Recurse | Where-Object{ $_.Name -match '.*([0-9]{4})(0[1-9]|1[0-2])(0[1-9]|[1-2][0-9]|3[0-1])_(2[0-3]|[01][0-9])([0-5][0-9])([0-5][0-9]).(jpg)$'}

foreach ($foto in $fotos) 
{
    $fechaHora=($foto.Name).Split("_")
    $d=[datetime]::ParseExact($fechaHora[0], "yyyyMMdd", $null).DayofWeek
    $d=obtenerDia($d)
    $hora=obtenerHora($fechaHora[1])
    if($Dia.ToUpper() -ne $d.Replace("á","a").Replace("é","e").ToUpper())
    {
        $calendario = $fechaHora[0] -replace '(\d{4})(\d{2})(\d{2})', '$3-$2-$1'
        Rename-Item (Get-ChildItem -Path $Directorio\"$foto" -Recurse) "$calendario $hora del $d.jpg"
    }
    
}

