#!/bin/bash
echo "El valor del parametro 1 es : " $1
echo "El valor del parametro 2 es :" $2
echo "La cantidad de parametros enviados es :" $#
echo "La lista de los parametros es: " $@
echo "Mi PID es" $$
mkdir test
echo "La salida es" $?
mkdir test
echo "La salida es" $?
sleep 1 &
echo "El pid de mi hijo es: " $! 
