<img src="./logo.png" />

<h1 align="center">Mémo et Script GNU/Linux</h1>

## Script

- Modification de la [ZRAM](https://github.com/aaaaaaantoine/archlinux-conf/blob/main/zram.sh)

- Création d'une base de donnée [MariaDB](https://github.com/aaaaaaantoine/archlinux-conf/blob/main/mariadb.sh)

- Serveur [LAMP](https://github.com/aaaaaaantoine/archlinux-conf/blob/main/debian-lamp.sh) Debian

- Serveur [Nextcloud](https://github.com/aaaaaaantoine/archlinux-conf/blob/main/nextcloud.sh) Debian

- Serveur [FTP](https://github.com/aaaaaaantoine/archlinux-conf/blob/main/debian-vsftpd.sh) Debian

## Mémo

- Mémo [UFW](https://github.com/aaaaaaantoine/archlinux-conf/blob/main/UFW.md)

- Mémo [VboxManage](https://github.com/aaaaaaantoine/archlinux-conf/blob/main/VboxManage.md)

- Mémo [IP Statique](https://github.com/aaaaaaantoine/archlinux-conf/blob/main/ip-static.md) Debian


# Installation d'un serveur Debian ; de A à Z.

# Configuration de Debian 12 Bookworm 

La première étape consiste à sélectionner [Debian](https://cdimage.debian.org/debian-cd/current/amd64/bt-cd/)

Procédez ensuite à l'installation de votre serveur avec les paramètres sans interface graphique pour plus de légéreté.

Une fois l'installation effectuée, connectez-vous au serveur en SSH avec les identifiants que vous aurez entré pendant l'installation. 

Lors de votre première connexion SSH au serveur, il faudra impérativement mettre à jour l'OS pour être sûr de bénéficier de la dernière version de l'OS qui comprennent très souvent les dernières mises à jour de sécurité de la distribution :

```
sudo apt update
sudo apt full-upgrade
```

Vous pouvez changer de mot de passe administrateur avec `sudo passwd`

# Sécurisez son serveur

La sécurité de votre serveur est un élément fondamental à ne pas négliger pour la vie de votre serveur. 

Nous allons donc suivre les étapes suivantes :

- Sécuriser l'accès via SSH (cela implique de :
	- Désactiver l'authentification SSH par saisie d'un mot de passe.
	- Restreindre l'authentification à distance avec le compte **root**.
	- Restreindre l'accès à IPv4 et IPv6.)
- Installer et configurer un Firewall

### Sécuriser l'accès via SSH

Commencez par créer un nouvel utilisateur : `usermod -a  -G  sudo  <username>` 

Ouvrez le fichier de configuration du service SSH du serveur :  `sudo nano /etc/ssh/sshd_config`

Trouvez les lignes suivantes :
```
PasswordAuthentication yes  
PermitRootLogin yes
```
Désactivez les accès par mot de passe et sur le compte root :
```
PasswordAuthentication no  
PermitRootLogin no
```

### Installer et configurer un Firewall
Un Firewall permet de filtrer les connexions entrantes et sortantes. Nous allons donc procéder à l'installation de [UFW](https://github.com/aaaaaaantoine/debian-server-guide/blob/main/UFW.md) qui permet de configurer avec une certaine facilité les interfaces réseaux via **iptables**.

`sudo apt install ufw`

Dans un premier temps faites en sorte d'activer la connexion sur les protocoles SSH, HTTP, et HTTPS :

```
sudo ufw allow ssh  
sudo ufw allow http  
sudo ufw allow https
```

Vous pouvez désormais activer le service UFW : `sudo ufw enable`
Si vous souhaitez consulter la liste des services autorisés / interdit par le Firewall : `sudo ufw status`
A tout moment, vous pouvez décider de le désactiver de la manière suivante : `sudo ufw disable`

## Installation de LAMP pour Linux Apache MariaDB PHP

Installons notre serveur [LAMP](https://github.com/aaaaaaantoine/debian-server-guide/blob/main/debian-lamp.sh)

```
sudo apt update && sudo apt full-upgrade -y
sudo apt install apache2 mariadb-server php php-gd php-mbstring php-xml php-zip php-curl php-mysql -y
sudo systemctl enable --now apache2 mariadb
sudo mysql_secure_installation
```

### Base de données MySQL / MariaDB

Debian est livré par défaut avec le paquet mariadb-server qui est en réalité la version open source de MySQL.

Création de notre base de donnée [MariaDB](https://github.com/aaaaaaantoine/debian-server-guide/blob/main/mariadb.sh):

```
# CREATE DATABASE antoine;
# GRANT ALL ON antoine.* TO 'antoine'@'localhost' IDENTIFIED BY 'Mot_De_Passe';
# FLUSH PRIVILEGES;
# exit;
```

Une fois effectué, vous devez configurer MySQL très facilement en exécutant la commande `mysql_secure_installation`. Vous pouvez laisser les valeurs par défaut suggérées par l'installateur interactif mais tâchez de définir un mot de passe au compte `root` MySQL.

Une fois l'installation terminée, vérifiez que le service MySQL est bien lancé : `systemctl status mysqld`
Vous pouvez tester la connexion à la base de données : `mysql -u root -p` (*saisissez votre mot de passe root*)

Il vous faut dorénavant configurer les privilèges pour MariaDB, rien de bien compliqué.

## Installation de Nextcoud

Nextcloud est un logiciel libre de site d'hébergement de fichiers et une plateforme de collaboration. À l'origine accessible via WebDAV, n'importe quel navigateur web, ou des clients spécialisés, son architecture ouverte a permis de voir ses fonctionnalités s'étendre depuis ses origines.

```
cd /tmp
sudo wget <https://download.nextcloud.com/server/releases/latest.zip>
sudo unzip latest.zip
sudo mv nextcloud /var/www/html/nextcloud
sudo chown -R www-data:www-data /var/www/html/nextcloud
```

**Paramétrage du Virtual Host**

Ici on utilisera Apache :
Copiez le fichier de configuration Apache par défaut et renommez-le en fonction du nom de domaine sur lequel vous souhaitez l'héberger :
`sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/nextcloud.conf`

Editez-le pour le paramétrer de la manière suivante : 
`sudo vim /etc/apache2/sites-available/nextcloud.conf`

```
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

Apache2 vous offre la possibilité d'activer votre fichier de configuration facilement avec la commande embarquée suivante : `sudo a2ensite nextcloud.conf`

Enfin, redémarrez le service Apache pour prendre en compte votre configuration : `sudo systemctl restart apache2`.

En toute logique, votre application est dorénavant accessible depuis l'interface HTTP *-- qui tourne sur le port 80 de votre serveur--* à l'adresse : https://IP_Server
