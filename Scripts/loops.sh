#!/bin/bash
echo "WHILE"
CONT=0
while [ $CONT -lt 10 ]; do
	echo "CONT:" $CONT
	let CONT=CONT+1
done

echo "UNTIL"
CONT=0
until [ $CONT -gt 10 ]; do
	echo "CONT:" $CONT
	let CONT=CONT+1
done

echo "FOR"
for (( i=0; i<10; i++ ))
do
	echo $i
done

echo "FOR PARA CADENAS"
for palabra in Hola a todos
do
	echo El valor actual de \$palabra es: $palabra
done



exit 1
fi
