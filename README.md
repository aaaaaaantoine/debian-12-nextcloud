<img src="./logo.png" />


<h1 align="center">Installation d'un Serveur Debian avec Nextcloud</h1>


# Configuration de Debian 12 Bookworm 

La première étape consiste à télécharger Debian [NetInstall](https://cdimage.debian.org/debian-cd/current/amd64/bt-cd/)

Procédez ensuite à l'installation de votre serveur avec les paramètres sans interface graphique pour plus de légéreté.

Une fois l'installation effectuée, connectez-vous au serveur en SSH avec les identifiants que vous aurez entré pendant l'installation. 

Lors de votre première connexion SSH au serveur, il faudra impérativement mettre à jour l'OS pour être sûr de bénéficier de la dernière version de l'OS qui comprennent très souvent les dernières mises à jour de sécurité de la distribution :

```
sudo apt update && sudo apt full-upgrade
```

Vous pouvez changer de mot de passe administrateur avec `sudo passwd`

# Sécurisez son serveur

La sécurité de votre serveur est un élément fondamental à ne pas négliger pour la vie de votre serveur. 

Nous allons donc suivre les étapes suivantes :

- Sécuriser l'accès via SSH (cela implique de :
	- Désactiver l'authentification SSH par saisie d'un mot de passe.
	- Restreindre l'authentification à distance avec le compte **root**.
- Installer et configurer un Firewall
- Fixer l'IP de sa machine
- Installer une interface graphique basée sur le Web

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

`sudo apt install ufw -y`

Dans un premier temps faites en sorte d'activer la connexion sur les protocoles SSH, HTTP, et HTTPS :

```
sudo ufw allow ssh  
sudo ufw allow http  
sudo ufw allow https
```

Vous pouvez désormais activer le service UFW : `sudo ufw enable`
Si vous souhaitez consulter la liste des services autorisés / interdit par le Firewall : `sudo ufw status`
A tout moment, vous pouvez décider de le désactiver de la manière suivante : `sudo ufw disable`

### Fixer l'IP de son seveur

Activer l'adresse IP statique

Par défaut, vous trouverez la configuration suivante dans le fichier de configuration réseau /etc/network/interfaces : `sudo vim /etc/network/interfaces`

Ajouter les lignes et modifiez les selon votre configuration

```
auto enp0s3 iface
enp0s3 inet static
address 192.168.1.11
netmask 255.255.255.0
gateway 192.168.1.1
```

### Installer une Web Console

Cockpit est une interface graphique basée sur le Web qui permet une gestion simple et intuitive des systèmes Linux. Il est conçu pour simplifier les tâches d'administration système quotidiennes telles que la surveillance des ressources système, la gestion des comptes d'utilisateurs, le démarrage et l'arrêt des services et la gestion du stockage.

```
sudo apt install -y cockpit cockpit-networkmanager cockpit-packagekit cockpit-pcp cockpit-storaged cockpit-system cockpit-ws
sudo systemctl enable --now cockpit.socket
```

Cockpit écoute sur le port 9090 votre machine donc ici vous utilisez UFW : `sudo allow 9090`

## Installation de LAMP (Linux Apache MariaDB PHP)

Installons notre serveur LAMP
```
sudo apt install apache2 mariadb-server php php-gd php-mbstring php-xml php-zip php-curl php-mysql -y
sudo systemctl enable --now apache2 mariadb
```

### Base de données MySQL / MariaDB

Debian est livré par défaut avec le paquet mariadb-server qui est en réalité la version open source de MySQL.

Une fois effectué, vous devez configurer MySQL très facilement en exécutant la commande `mysql_secure_installation`. Vous pouvez laisser les valeurs par défaut suggérées par l'installateur interactif mais tâchez de définir un mot de passe au compte `root` MySQL.

Création de notre base de donnée MariaDB : `sudo mysql -u root -p`

```
# CREATE DATABASE antoine;
# GRANT ALL ON antoine.* TO 'antoine'@'localhost' IDENTIFIED BY 'Mot_De_Passe';
# FLUSH PRIVILEGES;
# exit;
```

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

Ici pour la configuration, on utilisera Apache :
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

En toute logique, votre application est dorénavant accessible depuis l'interface HTTP de votre serveur.