# Practica01-10IAW
Este repositorio es para la Práctica 1 apartado 10 de IAW

## ¿ Que tenemos que hacer en esta práctica?

- En esta práctica tenemos que crear un *_balanceador de carga_*, que es un hardware o software que se pone al frente de una serie de servidores y se encarga de balancear las peticiones que llegan a ambos servidores, de manera que pueda alternar entre uno y otro.

- El esquema que tendremos que seguir será el siguiente:

    ![](images/cap1.png)

- Asi mismo tendremos que tener cuatro máquinas en funcionamiento que serán las siguientes:

    1. FrontEnd1
    2. BackEnd1
    3. FrontEnd2
    4. Sg Load Balancer (El balanceador)


## ¿ Que scripts tendremos que tener en nuestra práctica? 

- Tendremos que tener los siguientes pero como en la [Práctica 1-09IAW](https://github.com/kinoibanez/Practica01-9IAW) tenemos que tener mucho *_CUIDADO_* donde ejecutamos cada script, por que si no, haremos un lio entre las máquinas.


## Scripts *_Install_lamp_*

- Como hemos tenido anteriormente en prácticas, tenemos que tener dos scripts que se dediquen a instalar la pila LAMP con sus respectivas configuraciones tanto en el front como en el back.

- El primero que tenemos es el *_install_lamp_frontend_* que tendremos que ejecutar en ambas máquinas FRONT, cuidado con equivocarse.

    ``` 
    #!/bin/bash

    #Esto muestra todos los comandos que se van ejecutando
    set -ex 
    #Actualizamos los repositorios
    apt update

    #Actualizamos los paquetes de la máquina 

    #apt upgrade -y

    #Incluimos las variables del archivo .env

    source .env

    #Eliminamos instalaciones previas 

    rm -rf /tmp/wp-cli.phar

    # Descargamos la utilidad de wp-cli

    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp

    #Le asignamos permisos de ejecución al archivo wp-cli.phar

    chmod +x /tmp/wp-cli.phar

    #Movemos el archivo al directorio /usr/local/bin que almacena el listado de comandos del sistema.

    mv /tmp/wp-cli.phar /usr/local/bin/wp #wp es renombrado


    #Eliminamos instalaciones previas de wordpress

    rm -rf /var/www/html/*

    #Descargamos el codigo fuente de wordpress en /var/wwW/html

    wp core download --locale=es_ES --path=/var/www/html --allow-root

    #Crear el archivo .config, podemos comprobar haciendo un cat cat /var/www/html/wp-config.php si estan bien las variables

    wp config create \
    --dbname=$WORDPRESS_DB_NAME \
    --dbuser=$WORDPRESS_DB_USER \
    --dbpass=$WORDPRESS_DB_PASSWORD \
    --dbhost=$WORDPRESS_DB_HOST \
    --path=/var/www/html \
    --allow-root


    #Instalamos el directorio WORDPRESS con las variables de configuración en .env

    wp core install \
    --url=$CERTIFICATE_DOMAIN \
    --title="$WORDPRESS_TITLE"\
    --admin_user=$WORDPRESS_ADMIN_USER \
    --admin_password=$WORDPRESS_ADMIN_PASS \
    --admin_email=$WORDPRESS_ADMIN_EMAIL \
    --path=/var/www/html \
    --allow-root

    #Copiamos el archivo .htaccess

    cp ../htaccess/.htaccess /var/www/html/


    # Descargamos un plugin para la seguridad de WordPress

    sudo wp plugin install wp-staging --activate --path=/var/www/html --allow-root


    #Descargamos un tema cualquiera para la configuración

    #sudo wp  theme install Hestia --activate list --path=/var/www/html --allow-root

    #Descargamos un pluggin cualquiera.

    wp plugin install bbpress --activate --path=/var/www/html --allow-root

    #Links

    wp plugin install wps-hide-login --activate --path=/var/www/html --allow-root


    #Modificar nombres

    wp option update whl_page "NotFound" --path=/var/www/html --allow-root

    #Coniguramos el nombre de la entrada 

    wp rewrite structure '/%postname%/' --path=/var/www/html --allow-root

    #Modificamos los permisos de /var/www/html

    chown -R www-data:www-data /var/www/html

    ```

    Como podemos observar cada linea de código va comentada, en este script estamos lanzando WordPress con su respectiva configuración como pueden ser plugins, temas, etc... e incluso en el apartado final estamos cambiando la *URL* para que el acceso a través de *_wp-admin_* sea secreto solo para nosotros.


- El *_deploy_backend_* como bien sabemos la principal configuración que tiene es borrar y volver a crear la base de datos cada vez que ejecutemos su script.


    ```

    #!/bin/bash

    #Esto muestra todos los comandos que se van ejecutando
    set -ex 
    #Actualizamos los repositorios
    apt update

    #Actualizamos los paquetes de la máquina 

    #apt upgrade -y

    #Incluimos las variables del archivo .env

    source .env
    # Creamos la base de datos y el usuario de base de datos.

    mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
    mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
    mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
    mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
    mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
    ```

    Pero estos scripts ya lo hemos usado en prácticas anteriores que encontramos en mi misma página de GitHub.

### *_Install_lamp_* del Balanceador.

- Ahora es cuando entra la nueva configuración del nuevo script, este script tiene la función es modificar un archivo llamado *_load-balancer.conf_* que anteriormente tendremos que haber creado, para así poder indicar las dos IPS que tienen nuestros FRONT para poder redirigirte cada vez a uno cada vez que refresques la página. Es lioso, lo sé, pero podemos verlo de manera más simple a través del script.

    1. Nuestro archivo `.env` configurado con las IPS privadas de nuestro front end 1 y 2.

         ![](images/cap2.png)
    
    2. En el script haremos uso de *_sed -i_* que como bien sabemos sier
### Scripts deploy.

- El primer script que tenemos que hemos utilizado en prácticas anteriores es el *_deploy_frontend_*, este script deberemos lanzarlo en los dos FrontEnd que tenemos, de manera que dos tengan instalado apache y sus correspondientes pluggins.