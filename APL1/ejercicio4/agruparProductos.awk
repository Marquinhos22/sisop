BEGIN	{
    FS=","
}

{   
    totales[$1]+=$2
}

END	{
    unset FS
    
    for(producto in totales){
        
        print producto","totales[producto]
    }
}