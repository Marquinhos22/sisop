BEGIN {
    FS=","
}

{   
    
    if(cantReg>1){

        if(NR==1){

            printf("{%s: %s, ",$1,$2)

        } else {

            if(NR!=cantReg){
                printf("%s: %s, ",$1,$2)
            } else {
                printf("%s: %s }",$1,$2)
            }

        }
    } else {

        printf("{%s: %s }",$1,$2)

    }

   
}
