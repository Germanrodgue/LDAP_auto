#!/bin/bash
#inicializo variables necesarias para ejecutar el proceso
vNameHost="NombreHostEquipoOrigen"
vCarpetaCompartida="NombreCarpetaCompartidaEnEquipoOrigen"
vNameUser="NombreUsuarioEnEquipoOrigen"
vPassword="ContraseniaDeUsuarioEnEquipoOrigen"
vFecha=$(date +%Y.%m.%d_%H.%M)
vRutaDestino="/home/administrador/Desktop/BackUpClientesSamba"
vNameFile="/BackUp_resguardo_$vFecha.tar"

nCont=1
#realizo la operacion 3 veces para asegurarme que no hubo error en alguna recepcion de paquetes
while [ $nCont -le 3 ]; do
  ping $vNameHost -c 1
  if [ $? -ne 1 ]; then
    #el host esta en linea y procedo a realizar la copia de seguridad
    smbtar -s $vNameHost -x $vCarpetaCompartida -u $vNameUser -p $vPassword -t $vRutaDestino$vNameFile
    bzip2 $vRutaDestino$vNameFile
    #elimino las copias mas antiguas a 45 dias
    find $vRutaDestino/*.tar* -mtime +45 -exec rm {} \;
    #me aseguro de que el bucle ya no vuelva a ejecutarse
    nCont=4
  fi
  let nCont=$nCont+1

