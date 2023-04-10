#!/bin/sh
#
# genera archivo de usuarios ORACLE
#
#
# levanta variables de ambiente
#
cd /conectum/Areas/TI/crones/Ariba/
source ./tct_var.env
#
#
# obtiene datos de Oracle y los guarda a un archivo de texto
#
( echo "@/conectum/Areas/TI/crones/Ariba/OC_Ariba_Oracle.sql" | sqlplus bolinf/welcome12@pgpd1i)
#
#
# copia los datos obtenidos de Oracle a MySQL
#
MYSQL_LOG=mysql.log
#
echo "Update:"$(date) > $MYSQL_LOG
( mysql -ugerardo.vargas -pacapulco0310 < "/conectum/Areas/TI/crones/Ariba/OC_Oracle_MySQL.sql") >> $MYSQL_LOG

