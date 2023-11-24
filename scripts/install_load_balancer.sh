#!/bin/bash

#Esto muestra todos los comandos que se van ejecutando
set -x 
#Actualizamos los repositorios
apt update

#Actualizamos los paquetes de la máquina 


#apt upgrade -y

source  .env
# Instalamos el servidor web apache A.

apt install apache2 -y

#Habilitamos los modulos necesarios para configurar apache como proxy inverso.

sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_balancer

#Habilitamos el balanceo de carga Round Robin

sudo a2enmod lbmethod_byrequests


#copiamos el archivo de configuración 

sudo cp ../conf/load-balancer.conf /etc/apache2/sites-available

#Remplazamos los valores de la plantilla con la dirección IP de los frontales 

sed -i "s/IP_HTTP_SERVER_1/$IP_HTTP_SERVER_1/" /etc/apache2/sites-available/load-balancer.conf
sed -i "s/IP_HTTP_SERVER_2/$IP_HTTP_SERVER_2/" /etc/apache2/sites-available/load-balancer.conf

#Habilitamos el virtualhost que hemos creado.

sudo a2ensite load-balancer.conf 

#Deshabilitamos el que tiene apache por defecto.

sudo a2dissite 000-default.conf 

#Reiniciamos el servicio

sudo systemctl restart apache2


