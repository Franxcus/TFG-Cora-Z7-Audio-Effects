#!/bin/sh                                                                       
                                                                                
echo "Content-Type: text/plain"                                                 
echo ""                                                                         
                                                                                
case "$QUERY_STRING" in                                                         
    efecto=0) EFECTO=0 ;;                                                       
    efecto=1) EFECTO=1 ;;                                                       
    efecto=2) EFECTO=2 ;;                                                       
    efecto=3) EFECTO=3 ;;                                                       
    efecto=4) EFECTO=4 ;;                                                       
    efecto=5) EFECTO=5 ;;                                                       
    *)                                                                          
        echo "ERROR"                                                            
        exit 1                                                                  
        ;;                                                                      
esac                                                                            
                                                                                
/usr/bin/control-efecto "$EFECTO"                                               
echo "OK"
