#configurant el interfaz de red
ip=`cat $1 | grep ^ip | cut -f2 -d:`
sudo ifconfig eth1 $ip
sudo ifconfig eth1 netmask 255.255.255.0
sudo ifconfig eth1 down
sudo ifconfig eth1 up
echo "Selecciona la ip de la red"
ifconfig | grep -w inet | tr -s " " " " | cut -f3 -d" " | cut -f2 -d:
read ipred
echo "Selecciona la interfaz de red conectada a internet"
ifconfig | grep eth | tr -s " " " " | cut -f1 -d" "
read interfaz
#
#activar enrutament
echo "Creant script per activar el enrutament.."
sudo iptables -A FORWARD -j ACCEPT 
sudo iptables -t nat -A POSTROUTING -s $ipred/24 -o $interfaz -j MASQUERADE
echo "1" > ip_forward
sudo cp ip_forward /proc/sys/net/ipv4
#
#activar enrutament en un script
echo sudo iptables -A FORWARD -j ACCEPT >> scriptenrutament.sh
echo sudo iptables -t nat -A POSTROUTING -s $ipred/24 -o $interfaz -j MASQUERADE >> scriptenrutament.sh
sudo chmod 777 scriptenrutament.sh
echo "echo "1" > ip_forward" >> scriptenrutament.sh
echo cp ip_forward /proc/sys/net/ipv4 >> scriptenrutament.sh
#
#iniciar el script al iniciar el sistema
sudo mv ./scriptenrutament.sh /etc/init.d/ 2>1
sudo chmod +x /etc/init.d/scriptenrutament.sh 2>1
sudo update-rc.d scriptenrutament.sh defaults 2>1
#
echo "Presiona una telca per a continuar.."
read
#configuracio del client
clear
echo "Configuració per al client:"
echo -------------------------------------------------------------
echo IP
ipredn=`echo $ipred | cut -f4 -d"."`
ipreda=`echo $ipred | cut -f1-3 -d"."`
echo "$ipreda.(Algun numero diferent a $ipredn)"
echo
echo DNS
cat /etc/resolv.conf | grep nameserver | cut  -f2 -d" "
echo
echo Mascara de red
sudo apt-get install ipcalc >/dev/null
ipcalc $ipred | grep Netmask | tr -s " " " " | cut -f2 -d" "
echo
echo Puerta de enlace
echo $ipred
echo -------------------------------------------------------------
#
echo
echo "Presiona una tecla per a continuar.."
read
#servidor ssh
echo "Vols instalar el servidor SSH?"
read n
if [ "$n" = "si" ] || [ "$n" = "SI" ]
        then
                sudo apt-get install openssh-server
                echo "Despres de aquesta instalació tens que configurar el redireccionament de ports en virtualbox"
               
fi

if [ "$n" = "no" ] || [ "$n" = "NO" ]
then
                echo  "Continuant amb la configuració i instal·lació de ldap"
		echo  "Presiona una tecla per a continuar"
		read
fi
               

sudo cp /etc/hosts .
domini=`cat $1 | grep ^domini | cut -f2 -d:`
echo $ip `hostname`.$domini `hostname` >> hosts
sudo cp hosts /etc/hosts
sudo apt-get install slapd ldap-utils
dc=`cat $1 | grep ^domini | cut -f2 -d: | cut -f1 -d.`
dc2=`cat $1 | grep ^domini | cut -f2 -d: | cut -f2 -d.`
grups=`cat $1 | grep ^grups | cut -f2 -d: | tr -s "," " "`
alumnes=`cat $1 | grep ^alumnes | cut -f2 -d: | tr -s "," " "` 
profes=`cat $1 | grep ^profes | cut -f2 -d: | tr -s "," " "`

echo > add_content.ldif

echo "dn: ou=Users,dc=$dc,dc=$dc2
objectClass: organizationalUnit
ou: Users

dn: ou=Groups,dc=$dc,dc=$dc2
objectClass: organizationalUnit
ou: Groups

" > add_content.ldif

gid=5000
uid=10000
for d in $grups
do
echo "dn: cn=$d,ou=Groups,dc=$dc,dc=$dc2
objectClass: posixGroup
cn: $d
gidNumber: $gid

" >> add_content.ldif
a="$d"
al=`cat $1 | grep ^$a | cut -f2 -d: | tr -s "," " "`
for k in $al
do

echo  "dn: uid=$k,ou=Users,dc=$dc,dc=$dc2
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: $k
sn: $k 
givenName: $k
cn: $k
displayName: $k
uidNumber: $uid
gidNumber: $gid
userPassword: server123
gecos: $k
loginShell: /bin/bash
homeDirectory: /home/$k
"  >> add_content.ldif
let uid=uid+1
done
let gid=gid+1
done
ldapadd -x -D cn=admin,dc=$dc,dc=$dc2 -W -f add_content.ldif

