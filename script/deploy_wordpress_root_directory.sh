#!/bin/bash

# Muestra todos los comandos que se han ejeutado.

set -ex

# Actualización de repositorios
 sudo apt update

# Actualización de paquetes
# sudo apt upgrade  

# Incluimos las variables del archivo .env.
source .env

# Eliminar el archivo de codigo fuente descargado previamente.
rm -rf /tmp/latest.zip*
# Descargamos el codigo fuente
wget http://wordpress.org/latest.zip -P /tmp

# Instalar el comando unzip.
apt install unzip -y

# Descomprimimos el archivo latest.zip
unzip -u /tmp/latest.zip -d /tmp/

# Eliminamos instalaciones previas de wordpress en /var/www/html
rm -rf /var/www/html/*

# Movemos el contenido de /tmp/wordpress a /var/www/html
mv -f /tmp/wordpress/* /var/www/html


# Creamos la base de la bbase de datos y el usuario de la base de datos.
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"

# Creamos nuestro archivo de configuración de wordpress

cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

# Configuramos las variables del archivo de configuracion de wordpress
sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/wp-config.php
sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/wp-config.php
sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/wp-config.php
sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/wp-config.php

# Cambiamos el propietario para wordpress.
chown -R www-data:www-data /var/www/html/

# Habilitamos el modulo mod_rewrite de apache.
a2enmod rewrite

# Copiar a /var/www/html el directorio htaccess
cp ../conf/.htaccess /var/www/html

# Reiniciamos el servicio.
systemctl restart apache2

# Cambiamos el propietario para wordpress.
chown -R www-data:www-data /var/www/html/