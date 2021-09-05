#!/bin/bash
if [[ $# != 1 ]]
then
	echo "Se pide 1 solo parametro"
	exit 1
fi


echo $1
if [[ -d $1 ]]
then
	echo "El parametro pasado es un DIRECTORIO"
elif [[ -r $1 ]] 
then
	echo "El parametro pasado tiene permisos de lectura"
fi
