#!/bin/sh
#
# genera archivo de usuarios ORACLE
#
#
# levanta variables de ambiente
#
cd /conectum/Areas/TI/crones/rbs/
source ./tct_var.env
#
#
# copia datos del LDAP de la Intranet hacia Oracle PGPDAI
#
( echo "@/conectum/Areas/TI/crones/rbs/rbs_get_ldap.sql" | sqlplus /nolog)
#
#
# genera datos de usuarios a un archivo de texto - POSADAS
#
( echo "@/conectum/Areas/TI/crones/rbs/rbs_get_usr_pos.sql" | sqlplus bolinf/welcome12@pgpdai)
#
#
# genera datos de usuarios a un archivo de texto - MEXICANA
( echo "@/conectum/Areas/TI/crones/rbs/rbs_get_usr_mxn.sql" | sqlplus bolinf/IgrcJMXU@mxn_pcmavi) 
#
#
#carga datos a MYSQL - TCT
#
MYSQL_LOG=mysql.log
#
echo "Update:"$(date) > $MYSQL_LOG
#
#( echo "USE RBS; TRUNCATE TABLE PEOPLE" | mysql -uroot -pV.ymH4JpXAUmY) >> $MYSQL_LOG
#
( mysql -ugerardo.vargas -pacapulco0310 < "/conectum/Areas/TI/crones/rbs/rbs_load_usr_mysql.sql") >> $MYSQL_LOG
#
#exit 
#
# set fileformat=unix



