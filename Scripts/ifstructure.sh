#!/bin/bash
if [[ $# != 1 ]]
then
	echo "Se necesita 1 parametro"
	exit 1
fi
var=$1
if [[ $var == 2 ]]
then
	echo "var es igual a 2"
elif [[ $var < 2 ]]
then
	echo "var es menor a 2"
else
	echo "var es mayor a 2"
fi

