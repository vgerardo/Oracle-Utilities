#!/bin/bash
#
# Created by Gerardo's High Tecnology Corporation
# Copyright August 2016
#
#  ________                              .___      
# /  _____/  ________________ _______  __| _/____  
#/   \  ____/ __ \_  __ \__  \\_  __ \/ __ |/  _ \ 
#\    \_\  \  ___/|  | \// __ \|  | \/ /_/ (  <_> )
# \______  /\___  >__|  (____  /__|  \____ |\____/ 
#        \/     \/           \/           \/       
#
# Genera informacion correspondiente a las cargas de PO y RCV por la interfaz de Ariba - Oracle; 
# esta informacion la guarda en archivos de estatus como cargadas Exitosamente o Con Error, 
# para que posteriormente sean enviados al servidor de Ariba (por otro proceso)
#

ORABD="grpdb01.dibos02.di-cloud.com:1526/GRPEBSD"
ORAUSR="BOLINF"
ORACLV="R2gnar0s"

SUBDIR=$(date +"%Y%m%d%H%M%S")
SPOOL_DIR="Spool/$SUBDIR"
LOG_FILE="$SPOOL_DIR/log.txt"
PO_BASE="/home/ITK/transactiondata/PurchaseOrder"
RCV_BASE="/home/ITK/transactiondata/Receipt"
ITK_SUBDIR=dbconnector$SUBDIR

export LD_LIBRARY_PATH="/usr/lib/oracle/11.2/client/lib/"
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8


function enviar_email() {
local v_mensaje="$1"
    
    echo "Se envia E-Mail para Notificar al Operador"
    
    # se usa nohup para que el script no espere el envio del correo
    nohup mail -s "Error en Genera Archivos Estatus: $SUBDIR" gerardo.vargas@accenture.com <<< "$v_mensaje"

}


#
#crea un sub-directorio por cada ejecucion del script, con el nombre YYYYMMDDHHMMSS
#
mkdir $SPOOL_DIR
RC=$?

if [ "$RC" -ne 0 ]; then   
   echo "PASO 1. ERROR. Ocurrio un error al crear Directorio: $SPOOL_DIR" > "Spool/error_"$SUBDIR".txt"    
   enviar_email "ERROR en Paso 1 no se pudo crear el Sub-Directorio, ver log: log_$SUBDIR.txt" 
   exit 1
else
   # Redirect stdout(1) and stderr(2) al mismo archivo
   exec 1> $LOG_FILE 2>&1
   printf 'INICIO: %s %s \n' $(date +"%Y-%m-%d %H:%M:%S")
   echo "PASO 1. Se creo el sub-directorio: $SPOOL_DIR"
fi


#
# crea los archivos de estatus, en el nuevo Sub-Directorio
#
echo "PASO 2. Generando archivos de estatus"
#sqlplus $USR_ORACLE/$CLV_ORACLE@$BD_ORACLE @genera_archivos.sql $SPOOL_DIR 
(echo "@crear_archivos.sql $SPOOL_DIR" | sqlplus -L -S $ORAUSR/$ORACLV@$ORABD)
RC=$?
if [ "$RC" -ne 0 ]; then
   echo "PASO 2. ERROR. en SQLPlus ver log." > "Spool/error_"$SUBDIR".txt"  
   enviar_email "ERROR en Paso 2, al ejecutar SQLPLUS, no se generaron correctamente los Archivos, ver log.txt: $SUBDIR" 
   exit 1
else
   echo "     Se generaron los archivos correctamente con SQLPLUS"   
fi


#
# envia los archivos al directorio de Salida del ITK, 
# para que el siguinte cron los envie hacia Ariba
#
echo "PASO 3. Inicia Copia de Archivos hacia el ITK"

CP_ERR=""

mkdir $PO_BASE/PurchaseOrder/inDir/$ITK_SUBDIR/
echo "     Se creo: $PO_BASE/PurchaseOrder/inDir/$ITK_SUBDIR/"
cp $SPOOL_DIR/PurchaseOrderIDImport.csv \
   $SPOOL_DIR/PurchaseOrderErrorImport.csv \
   $PO_BASE/PurchaseOrder/inDir/$ITK_SUBDIR/
RC=$?
if [ "$RC" -ne 0 ]; then   
    CP_ERR=" No se pudo copiar los archivos de <Creacion>."
fi

mkdir $PO_BASE/CancelPurchaseOrder/inDir/$ITK_SUBDIR/
echo "     Se creo: $PO_BASE/CancelPurchaseOrder/inDir/$ITK_SUBDIR/"
cp $SPOOL_DIR/PurchaseOrderCancelIDImport.csv \
   $SPOOL_DIR/PurchaseOrderCancelErrorImport.csv \
   $PO_BASE/CancelPurchaseOrder/inDir/$ITK_SUBDIR/
RC=$?
if [ "$RC" -ne 0 ]; then   
    CP_ERR="$CP_ERR \n No se pudo copiar los archivos de <Cancelacion>."
fi

mkdir $PO_BASE/ChangePurchaseOrder/inDir/$ITK_SUBDIR/
echo "     Se creo: $PO_BASE/ChangePurchaseOrder/inDir/$ITK_SUBDIR/"
cp $SPOOL_DIR/PurchaseOrderChangeIDImport.csv \
   $SPOOL_DIR/PurchaseOrderChangeErrorImport.csv \
   $PO_BASE/ChangePurchaseOrder/inDir/$ITK_SUBDIR/
RC=$?
if [ "$RC" -ne 0 ]; then   
    CP_ERR="$CP_ERR \n No se pudo copiar los archivos de <Actualizacion>."
fi

mkdir $RCV_BASE/inDir/$ITK_SUBDIR/
echo "     Se creo: $RCV_BASE/inDir/$ITK_SUBDIR/"
cp $SPOOL_DIR/ReceiptIDImport.csv \
   $SPOOL_DIR/ReceiptErrorImport.csv \
   $RCV_BASE/inDir/$ITK_SUBDIR/
RC=$?
if [ "$RC" -ne 0 ]; then   
    CP_ERR="$CP_ERR \n No se pudo copiar los archivos de <Recepciones>."
fi

#
# reporta los errores en la copia de archivos
#
if [ "$CP_ERR" != "" ]; then
    echo "ERROR: No se copiaron arhivos de estatus al directorio del ITK"
    echo -e $CP_ERR
    enviar_email "ERROR en Paso 3 no se pudo copiar archivos al ITK, ver log.txt: $SUBDIR" 
    exit 1
else    
    echo "     Se copiaron correctamente los archivos al directorio del ITK"
fi

echo " "
printf 'FIN: %s %s \n' $(date +"%Y-%m-%d %H:%M:%S")


