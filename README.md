<img src="./logo.png" />

# Debian 12 Nextcloud Serveur

**Objectifs**:

- Sécurisez son serveur
- Installation de la de pile LAMP
- Installation de Nextcoud
- Se connecter via http/https


**Configuration de Debian 12 Bookworm** 

### Prérequis
- Mettre à jour le système
- Avoir un accès root
```
apt update && apt full-upgrade -y
```
*Vous pouvez changer de mot de passe administrateur avec `sudo passwd`*

### Sécurisez son serveur

La sécurité de votre serveur est un élément fondamental à ne pas négliger pour la vie de votre serveur. 

Nous allons donc suivre les étapes suivantes :

- Sécuriser l'accès via SSH, cela implique de :
  - Générer une paire de clés ssh
  - Désactiver l'authentification SSH par saisie d'un mot de passe.
  - Restreindre l'authentification à distance avec le compte **root**.
  - Interdire la redirection graphique
  - Limiter la durée de l'authentification
  - Limier le nombre de tentatives d'accès
- Installer et configurer un Firewall
- Fixer l'IP de sa machine

**Sécuriser l'accès SSH**

Commencez par créer un nouvel utilisateur : `usermod -a  -G  sudo  <username>` 

Générer une paire de clés ssh et la copier dans votre serveur :

```
ssh-keygen -t rsa -C 'Antoine D' -b 4096
ssh-copy-id -i ~/.ssh/id_rsa username@remote_server
```

Ouvrez le fichier de configuration du service SSH du serveur :  `nano /etc/ssh/sshd_config`

Trouvez les lignes suivantes et modifiez, ajoutez les :

```
PasswordAuthentication no  
PermitRootLogin no
PubkeyAuthentication yes
X11Forwarding no
PrintLastLog yes
PermitEmptyPasswords no
LoginGraceTime 30
StrictModes yes
MaxAuthTries 3
ClientAliveInterval 0
ClientAliveCountMax 2
AllowUsers user0 user1
AllowGroups group0 group1
```

Pour prendre en compte les modifications, redémarrez le serveur ssh : `systemctl restart sshd`

**Installer et configurer un Firewall**

Un Firewall permet de filtrer les connexions entrantes et sortantes. Nous allons donc procéder à l'installation de UFW qui permet de configurer avec une certaine facilité les interfaces réseaux via **iptables**.

`apt install ufw -y`

Dans un premier temps faites en sorte d'activer la connexion sur les protocoles SSH, HTTP, et HTTPS :

```
ufw allow ssh  
ufw allow http  
ufw allow https
```

Vous pouvez désormais activer le service UFW : `sudo ufw enable`
Si vous souhaitez consulter la liste des services autorisés / interdit par le Firewall : `ufw status`
A tout moment, vous pouvez décider de le désactiver de la manière suivante : `ufw disable`

**Fixer l'IP de son seveur**

Activer l'adresse IP statique

Par défaut, vous trouverez la configuration suivante dans le fichier de configuration réseau /etc/network/interfaces : 

`vim /etc/network/interfaces`

Ajouter les lignes et modifiez les selon votre configuration

```
auto enp0s3 iface
enp0s3 inet static
address 192.168.1.11
netmask 255.255.255.0
gateway 192.168.1.1
```

### Installation de la de pile LAMP

Installons notre serveur LAMP
```
apt install apache2 mariadb-server php php-gd php-mbstring php-xml php-zip php-curl php-mysql -y
systemctl enable --now apache2 mariadb
```

**création d'une base de données MySQL / MariaDB**

Debian est livré par défaut avec le paquet mariadb-server qui est en réalité la version open source de MySQL.

Une fois effectué, vous devez configurer MySQL très facilement en exécutant la commande `mysql_secure_installation`. Vous pouvez laisser les valeurs par défaut suggérées par l'installateur interactif mais tâchez de définir un mot de passe au compte `root` MySQL.

Création de notre base de donnée MariaDB : `mysql -u root -p`

```
CREATE DATABASE test;
GRANT ALL ON antoine.* TO 'test'@'localhost' IDENTIFIED BY 'Mot_De_Passe';
FLUSH PRIVILEGES;
EXIT;
```

### Installation de Nextcoud

Nextcloud est un logiciel libre de site d'hébergement de fichiers et une plateforme de collaboration. À l'origine accessible via WebDAV, n'importe quel navigateur web, ou des clients spécialisés, son architecture ouverte a permis de voir ses fonctionnalités s'étendre depuis ses origines.

```
cd /tmp
wget <https://download.nextcloud.com/server/releases/latest.zip>
unzip latest.zip
mv nextcloud /var/www/html/nextcloud
chown -R www-data:www-data /var/www/html/nextcloud
```

**Paramétrage du Virtual Host**

Ici pour la configuration, on utilisera Apache :
Copiez le fichier de configuration Apache par défaut et renommez-le en fonction du nom de domaine sur lequel vous souhaitez l'héberger :
`cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/nextcloud.conf`

Editez-le pour le paramétrer de la manière suivante : 
`vim /etc/apache2/sites-available/nextcloud.conf`

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

Apache2 vous offre la possibilité d'activer votre fichier de configuration facilement avec la commande embarquée suivante : `a2ensite nextcloud.conf`

Enfin, redémarrez le service Apache pour prendre en compte votre configuration : `systemctl restart apache2`.

En toute logique, votre application est dorénavant accessible depuis l'interface HTTP de votre serveur.
