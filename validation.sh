#!bin/bash

#Variables
CONNECTION=$1
#Code

export ORACLE_SID=${CONNECTION}

#Truncate logfile 
echo > evidencia.log

#Get in SQLPLUS and execute validation script
sqlplus -s "/as sysdba" @valida_db.sql

ABERTO=`grep OPEN evidencia.log | wc -l`

if [ $ABERTO -ge 1 ]; then
    echo "Banco no ar"
    exit 0
else
sqlplus -s "/as sysdba"<<EOF
startup;
quit;
EOF
    sqlplus -s "/as sysdba" @valida_db.sql
fi