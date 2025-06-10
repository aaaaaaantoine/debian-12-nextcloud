# Installer Nextcloud une Debian 12 Serveur


## Mise à jour du système

```sh
apt update && apt full-upgrade
```


## Installer la de pile LAMP

* Installation de php et apache.

```sh
apt install apache2 php php-gd php-mbstring php-xml php-zip php-curl php-mysql
systemctl enable --now apache2
```

* Installation de MariaDB.

```sh
apt install -y mariadb-server
systemctl enable --now mariadb
```

* Création de la base données MariaDB pour Nextcloud.

```sh
mysql_secure_installation
```

Vous pouvez laisser les valeurs par défaut suggérées par l'installateur interactif mais tâchez de définir un mot de passe au compte `root` MySQL.

Création de notre base de donnée MariaDB 

```sh
mysql -u root -p
```
```sh
CREATE DATABASE test;
GRANT ALL ON antoine.* TO 'test'@'localhost' IDENTIFIED BY 'Mot_De_Passe';
FLUSH PRIVILEGES;
EXIT;
```

## Installation et configuration de Nextcoud

*Nextcloud est un logiciel libre de site d'hébergement de fichiers et une plateforme de collaboration. À l'origine accessible via WebDAV, n'importe quel navigateur web, ou des clients spécialisés, son architecture ouverte a permis de voir ses fonctionnalités s'étendre depuis ses origines.*

```
cd /tmp
wget <https://download.nextcloud.com/server/releases/latest.zip>
unzip latest.zip
mv nextcloud /var/www/html/nextcloud
chown -R www-data:www-data /var/www/html/nextcloud
```

* Configuratuon des Virtual Host
```sh
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/nextcloud.conf
```
```sh
vim /etc/apache2/sites-available/nextcloud.conf
```
```sh
<VirtualHost *:80>
     DocumentRoot /var/www/html/nextcloud/
     ServerName *IP_Server*

     <Directory /var/www/html/nextcloud/>
       Require all granted
       AllowOverride All
       Options FollowSymLinks MultiViews

       <IfModule mod_dav.c>
         Dav off
       </IfModule>

     </Directory>

</VirtualHost>
```

Apache2 vous offre la possibilité d'activer votre fichier de configuration facilement avec la commande embarquée suivante

```sh
a2ensite nextcloud.conf
```

Enfin, redémarrez le service Apache pour prendre en compte votre configuration 

```sh
systemctl restart apache2
```

En toute logique, votre application est dorénavant accessible depuis l'interface HTTP de votre serveur.
