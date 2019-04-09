#!bin/bash

#Variables

#Code

#ssh -t 192.168.56.101 -l oracle

#Truncate logfile 
echo > evidencia.log

#Get in SQLPLUS and execute validation script
sqlplus -s "/as sysdba" @valida_db.sql

ABERTO=`grep OPEN evidencia.log | wc -l`

if [ $ABERTO -ge 1 ]; then
    echo "Banco no ar"
    exit 0
else
    echo 'Banco baixado'
    exit 1
fi
