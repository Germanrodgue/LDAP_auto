#!/bin/sh
Nomhost=""
CarpetaCompartida="/"
Usuario=""
Pass=""
#Fecha=$(date +%Y.%m.%d_%H.%M)
RutaGuardar="/media/respaldo/3CC4-A668"
NomArchiu="BackUp_resguardo"

ping $Nomhost -c 1
if [ $? -ne 1 ]
 then
   smbtar -s $Nomhost -x $CarpetaCompartida -u $Usuario -p $Pass -t $RutaGuardar$NomArchiu

  fi


