	###################################
	#                                 #
	#        Trabajo Práctico 2       #
	#          Ejercicio Nº 1         #
	#           ejercicio1.sh         #
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
    
# ------------------------------------------------------------------ #

[CmdletBinding()]


<# 
El script recibe dos parámetros, los cuales no son obligatorios:
    -dirAExaminar
    -cantDirMostrar

• dirAExaminar debe ser un directorio válido 
• Si no se escribe "-dirAExaminar" para pasar este dato por
  parámetro a la hora de ejecutar el script, se lo toma por default en la segunda posición.
#>

Param (
[Parameter(Position = 1, Mandatory = $false)]
[ValidateScript( { Test-Path -PathType Container $_ } )]
[String] $dirAExaminar,
[int] $cantDirMostrar = 0
)

# $LIST contendrá todos los directorios que se encuentren en el path pasado por parámetro
$LIST = Get-ChildItem -Path $dirAExaminar -Directory

# Para cada directorio de $LIST
$ITEMS = ForEach ($ITEM in $LIST) {

    # Se obtiene la cantidad de elementos en los subdirectorios de $LIST.
    $COUNT = (Get-ChildItem -Path $ITEM).Length


    # Se le asigna a la variable $props una hashtable o array asociativo.
    $props = @{
        name = $ITEM
        count = $COUNT
}

    
    # Se crea un objeto que contiene la variable $props, usando: 
    #   • Las key como encabezados
    #   • Los valores como datos relacionados
    # Finalmente, el objeto es retornado al terminar el forEach.
    New-Object psobject -Property $props
}

# $ITEMS pasa a ser un objeto que contiene hashtables:
#   • Como encabezados las claves "name" y "count"
#   • Como filas los datos correspondientes

# Se ordena $ITEMS por cantidad de elementos de forma descendente, tomando  los primeros $cantDirMostrar (pasado por parametros) de la lista ordenada y el campo name.
$CANDIDATES = $ITEMS | Sort-Object -Property count -Descending | Select-Object -First $cantDirMostrar | Select-Object -Property name


Write-Output "Los subdirectorios con mas elementos son: "

# Se imprime $CANDIDATES sin los encabezados de tabla correspondientes.
$CANDIDATES | Format-Table -HideTableHeaders

<#
1-
El script tiene como objetivo que, a partir de un directorio y un numero "n" dados, se muestren los "n" subdirectorios ordenados de mayor a menor según la cantidad de elementos que contienen en su interior.
Recibe como parámetros:
    • Un directorio
    • El numero de subdirectorios finales a mostrar

Parametros renombrados:
    • $param1 --> $dirAExaminar
    • $param2 --> $cantDirMostrar

4-
Agregariamos 3 validaciones a los parametros:
    • Validar que cantDirMostrar sea un entero positivo.
    • Hacer ambos de caracter obligatorio.
    • Que el parámetro $dirAExaminar tenga permisos de lectura.

No se encontraron errores en el script.

5-
[CmdletBinding()] permite varias cosas:
    • Crear funciones avanzadas las cuales actúan como cmdlets (comandos que participan en la semántica del pipeline).
    • La habilidad de usar los commonParameters en el script. Por ejemplo: Debug (db), Verbose (vb), ErrorVariable (ev) con sus respectivas funciones como Write-Debug, Write-Verbose, etc.
    • La posibilidad de usar -WhatIf y -Confirm, para mayor interactividad con el usuario al momento de incluir [CmdletBinding()] en una función.

6-
Los tipos de comillas son: comillas dobles (“), comillas simples (‘) y acento grave (`):
    • Comillas dobles o débiles (“): permiten utilizar texto e interpretar variables al mismo tiempo.
    • Las comillas simples o fuertes (‘): generan que el texto delimitado entre ellas se utilice de forma literal, evitando que se interpreten las variables. 
    • El acento grave (`): , es el carácter de escape para evitar la interpretación de los caracteres especiales, como por ejemplo el símbolo $.

7-
Si se ejecuta el script sin ningún parámetro, muestra solamente el mensaje del final en el que se indica el resultado del script (linea 80).
Al estar $cantDirMostrar inicializada por defecto en 0, no se almacena nada en la variable $CANDIDATES. Al mostrarse su contenido, el mismo sera vacío.
#>