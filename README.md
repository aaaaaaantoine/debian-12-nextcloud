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

La première étape consiste à sélectionner [Debian 12]()

Procédez ensuite à l'installation de votre serveur avec les paramètres par défaut.

Une fois l'installation effectuée, connectez-vous au serveur en SSH avec les identifiants que vous aurez entré pendant l'installation. 

Lors de votre première connexion SSH au serveur, il faudra impérativement mettre à jour l'OS pour être sûr de bénéficier de la dernière version de l'OS qui comprennent très souvent les dernières mises à jour de sécurité de la distribution :

```sudo apt update && sudo apt upgrade```

Vous pouvez changer de mot de passe administrateur avec `sudo passwd`

# Sécurisez son serveur

La sécurité de votre serveur est un élément fondamental à ne pas négliger pour la vie de votre serveur. Peu importe que votre serveur soit "visité" ou bien qu'il ne soit destiné qu'à "voir des flux transités". C'est une étape cruciale qui doit être prise très au sérieux DÈS le début. A différentes échelles, en fonction de nombreux factures que vous ne pourrez prévoir, un certain nombre de personnes mal intentionnées (ou des *robots*) vont chercher, *-- pour des raisons qui vous échapperont bien souvent --* à se connecter à votre serveur par tous les moyens.

La première étape pour sécuriser votre serveur relève de l'observation et de l'analyse. Vous avez de la chance car sur un serveur Linux la grande majorité des actions internes et externes sont enregistrées dans des fichiers de logs systèmes et applicatifs.

Pour ce faire il existe plusieurs outils d'analyse et surveillance. Le premier dont je recommande l'installation est **fail2ban**.

**fail2ban** est une application qui analyse les logs de divers services (SSH, Apache, FTP…) en cherchant des correspondances entre des motifs définis dans ses filtres et les entrées des logs. Lorsqu'une correspondance est trouvée une ou plusieurs actions sont exécutées. Typiquement, fail2ban cherche des tentatives répétées de connexions infructueuses dans les fichiers journaux et procède à un bannissement en ajoutant une règle au pare-feu [iptables](https://doc.ubuntu-fr.org/iptables "iptables") pour bannir l'adresse IP de la source.

Installez le paquet de la manière suivante : `sudo apt install fail2ban`

Vous pouvez décider de laisser la configuration par défaut qui est suffisante pour le démarrage. Vous pourrez par la suite [personnaliser les règles de filtrage](http://www.fail2ban.org/wiki/index.php/Main_Page) en fonction de vos besoins.

La seconde étape, fondamentale elle aussi, doit veiller à ce que toute connexion entrante soit sécurisée de bout en bout. Cela implique de ne pas utiliser de mot de passe pour les connexions via SSH (port 22). Si vous souhaiter autoriser un utilisateur *-- quel qu'il soit --* à accéder à votre serveur, privilégiez la sécurisation par clé RSA (*c'est ce que nous allons mettre en place ici*).

Nous allons donc suivre les étapes suivantes :

- Sécuriser l'accès via SSH (cela implique de :
	- Désactiver l'authentification SSH par saisie d'un mot de passe.
	- Restreindre l'authentification à distance avec le compte **root**.
	- Restreindre l'accès à IPv4 et IPv6.)
- Installer et configurer un Firewall

### Sécuriser l'accès via SSH

Commencez par créer un nouvel utilisateur : `sudo adduser <username>`

Faites de cet utilisateur un `sudoer` (*quelqu'un qui peut "demander" d'exécuter des commandes en tant qu'administrateur du serveur*) : `usermod -a  -G  sudo  <username>` 

Si vous êtes sur MacOS ou une distribution Linux, envoyez la clé RSA de votre machine physique au serveur distant avec la commande suivante : `ssh-copy-id <username>@ip-du-serveur`

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

La dernière étape consiste à restreindre l'accès SSH aux connexions sur les interfaces IPv4 et IPv6 en modifiant la variable  **AddressFamily** . Pour autoriser uniquement les connexions sur IPv4 (qui est largement suffisant dans 90% des cas) :

`AddressFamily inet`

Redémarrez le service SSH pour prendre en considération le nouveau paramétrage : `sudo systemctl restart sshd`
**Note importante :** conservez au cas où une autre fenêtre où vous êtes déjà connecté(e) au serveur avant de redémarrer le service. Avoir une connexion active sur une seconde fenêtre vous permettra de corriger les erreurs si vous en rencontrez.

### Installer et configurer un Firewall
Un Firewall permet de filtrer les connexions entrantes et sortantes. Nous allons donc procéder à l'installation de [Uncomplicated Firewall](https://launchpad.net/ufw) (UFW) qui permet de configurer avec une certaine facilité les interfaces réseaux via **iptables**.

`sudo apt install ufw`

Attention, attention ! UFW interdit par défaut toutes les connexions entrantes et sortantes. Ce qui signifie que si vous ne terminez pas sa configuration correctement, vous pouvez vous retrouver bloqué(e) en dehors de votre serveur sans aucun moyen de récupérer votre accès SSH !

Dans un premier temps faites en sorte d'activer la connexion sur les protocoles SSH, HTTP, et HTTPS :

```
sudo ufw allow ssh  
sudo ufw allow http  
sudo ufw allow https
```

Vous pouvez désormais activer le service UFW : `sudo ufw enable`
Si vous souhaitez consulter la liste des services autorisés / interdit par le Firewall : `sudo ufw status`
A tout moment, vous pouvez décider de le désactiver de la manière suivante : `sudo ufw disable`

Autrement, la librairie [firewall-cmd](https://www.redhat.com/sysadmin/secure-linux-network-firewall-cmd?extIdCarryOver=true&sc_cid=701f2000001OH79AAG) est une bonne alternative également.

## 🔥 Installation de librairies systèmes additionnelles

Ce que j'appelle des "librairies systèmes additionnelles" sont des librairies qui peuvent s'avérer être utiles à l'administration et la maintenance efficace et cohérente du serveur.

La première librairie utile s'intitulé htop et peut être installée directement via le gestionnaire de paquets de la distribution : `apt install htop`

Lorsque vous exécuterez `htop` dans votre terminal SSH, un moniteur de ressources hardware s'affiche. Il liste également tous les process en cours d'exécution (l'équivalent visuel d'un `ps -aux`) sur le serveur. L'avantage qu'il offre est avant tout visuel, mais ses fonctionnalités sont d'une véritable aide lorsque, par exemple, vous souhaitez `kill` un process en particulier. Vous pouvez rechercher un process en cours par son nom, son PID, puis le terminer en deux raccourcis clavier (touches F1-2-X de votre clavier). Vous pouvez également naviguer au clavier et taper "Entrée ⏎"  de votre clavier.

## 🌍 Installation d'un serveur WEB

### Apache2
```sudo apt install apache2``` installera la dernière version de Apache2 stable avec ses dépendances.
N'oubliez pas d'activer les modules apache utiles suivants : `a2enmod rewrite ssl`
### Nginx
```sudo apt install nginx``` installera la dernière version de Nginx stable avec ses dépendances.
### Librairies PHP

Pour bénéficier des dernières versions stables (*et instables*) de PHP, il ne faut pas installer les paquets officiels  qui proviennent du repository officiel Debian ou votre hébergeur mais plutôt privilégier ceux qui sont récupérables depuis une source comme [https://packages.sury.org/php/](https://packages.sury.org/php/)

Créez un fichier `install_sury.sh` et copiez-y à l'intérieur le contenu suivant :

```
#!/bin/bash
# To add this repository please do:

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

${SUDO} apt-get -y install apt-transport-https lsb-release ca-certificates
${SUDO} wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
${SUDO} sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
${SUDO} apt-get update
```
Permettez l'exécution de ce script en tapant la commande : `sudo chmod +x install_sury.sh`
Exécutez ensuite ce script  : `./install_sury.sh`
Si tout s'est bien déroulé, vous pouvez supprimer ce script.

Installez ensuite PHP 7.3 avec : `sudo apt install php7.3`
Ainsi que d'autres dépendances utiles et fondamentales au bon fonctionnement de PHP et Laravel :
`sudo apt install php7.3-cli php7.3-common php7.3-curl php7.3-mbstring php7.3-mysql php7.3-xml`

### Base de données MySQL / MariaDB

Debian est livré par défaut avec le paquet mariadb-server qui est en réalité la version open source de MySQL : le moteur MariaDB.

Installez donc MariaDB avec la commande suivante : `sudo apt install mariadb-server mariadb-client mariadb-common` (sur une version Debian < 10, remplacez `mariadb-` par `mysql-`

Une fois effectué, vous devez configurer MySQL très facilement en exécutant la commande `mysql_secure_installation`. Vous pouvez laisser les valeurs par défaut suggérées par l'installateur interactif mais tâchez de définir un mot de passe au compte `root` MySQL.

Une fois l'installation terminée, vérifiez que le service MySQL est bien lancé : `systemctl status mysqld`
Vous pouvez tester la connexion à la base de données : `mysql -u root -p` (*saisissez votre mot de passe root*)

Il vous faut dorénavant configurer les privilèges pour MariaDB, rien de bien compliqué.

### Composer & NPM/YARN

**Quoi de mieux que Composer pour gérer vos packages et dépendances PHP ?**

Créez un fichier `install_composer.sh` et copiez-y à l'intérieur le contenu suivant :
```bash
#!/bin/sh

EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
then
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php --quiet --install-dir=bin
RESULT=$?
rm composer-setup.php
exit $RESULT
```

Permettez l'exécution de ce script en tapant la commande : `sudo chmod +x install_composer.sh`
Exécutez ensuite ce script  : `./install_composer.sh`
Si tout s'est bien déroulé, vous pouvez supprimer ce script.

**Quoi de mieux que NPM / YARN pour gérer vos dépendances NodeJS ?**

Avant toute chose il faut pré-installer le PPA NodeJS (*Personal Packages Archives*) :
Dernière version :  
```
sudo apt-get install curl software-properties-common
curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
```
Version stable : 
```
sudo apt-get install curl software-properties-common
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
```

Enfin installez NodeJS et vérifiez la version installée :

```
sudo apt-get install nodejs
node -v
npm -v
```

## 🏡 Hébergement de votre application (Laravel pour exemple)

Vous avez installé Apache2 ou Nginx et vous décidez d'héberger votre application développée en Laravel ? Vous êtes au bon endroit.

La première étape consiste à déplacer votre projet au bon endroit. Votre application est donc à déplacer / déployer dans le dossier suivant : `/var/www/html/<mon-application>`

Installez ensuite les dépendances Laravel : `composer install` une fois que vous êtes dans le dossier de votre application. N'oubliez pas enfin d'éditer votre fichier d'environnement responsable notamment de la connexion à votre base de données : `sudo nano /var/www/html/<mon-application>/.env`

Ne pas omettre d'effectuer vos migrations et seeds si vous en avez : `php artisan migrate && php artisan db:seed`

**Paramétrage du Virtual Host**

Pour atteindre désormais l'endpoint HTTP(S) de votre application, vous devrez paramétrer ce que l'on appelle communément un "Virtual Host". Le Virtual Host est en effet important car il définit les règles d'accès à votre application. Sachant que votre application est accédée depuis l'utilisateur système `www-data`, vous devez redéfinir les droits de votre application depuis le dossier de cette dernière comme suit : 

```
sudo chown -R www-data: .
sudo chmod -R ug+rwx storage bootstrap/cache
```

**Si vous utilisez Nginx :**
Copiez le fichier de configuration Nginx par défaut et renommez-le en fonction du nom de domaine sur lequel vous souhaitez l'héberger (*attention, ce dernier doit pointer dans sa configuration DNS vers l'adresse IP du serveur sur lequel vous vous trouver*) :
`sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/mon-application.com`

Editez-le pour le paramétrer de la manière suivante : 
`sudo nano /etc/nginx/sites-available/mon-application.com`

```
server {
    listen 80;
    listen [::]:80;

    . . .

    root /var/www/html/<mon-application>/public;
    index index.php index.html index.htm index.nginx-debian.html;

    server_name mon-application.com www.mon-application.com;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    . . .
}
```

Créez un lien symbolique pour que le fichier de configuration actif fasse référence à votre fichier de configuration : `sudo ln -s /etc/nginx/sites-available/mon-application.com /etc/nginx/sites-enabled/`

Enfin, redémarrez le service Nginx pour prendre en compte votre configuration : `sudo systemctl reload nginx`

**Si vous utilisez Apache :**
Copiez le fichier de configuration Apache par défaut et renommez-le en fonction du nom de domaine sur lequel vous souhaitez l'héberger (*attention, ce dernier doit pointer dans sa configuration DNS vers l'adresse IP du serveur sur lequel vous vous trouver*) :
`sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/mon-application.com.conf`

Editez-le pour le paramétrer de la manière suivante : 
`sudo nano /etc/apache2/sites-available/mon-application.com.conf`

```
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
	ServerName mon-application.com
    ServerAlias www.mon-application.com
    DocumentRoot /var/www/html/<mon-application>/public

	<Directory /var/www/html/<mon-application>/>  
		Options All
		AllowOverride All
		Order Allow,Deny
		Allow from all
	</Directory>

    ErrorLog ${APACHE_LOG_DIR}/error-mon-application.log
    CustomLog ${APACHE_LOG_DIR}/access-mon-application.log combined
</VirtualHost>
```

Apache2 vous offre la possibilité d'activer votre fichier de configuration facilement avec la commande embarquée suivante : `sudo a2ensite mon-application.com.conf`

Enfin, redémarrez le service Apache pour prendre en compte votre configuration : `sudo systemctl restart apache2`.

En toute logique, votre application est dorénavant accessible depuis l'interface HTTP *-- qui tourne sur le port 80 de votre serveur--* à l'adresse : https://www.mon-application.com (et ça devrait fonctionner également sans le *"www"* 😉)

## 🤝 Contribution

Les contributions à ce guide sont les bienvenues en tout temps ! 😍

## Manifestez votre intérêt

Soutenez ce repo ⭐️ si ce guide s'est avéré utile pour vous ! 🥰

<p align="center">Made with ❤️ by <a href="https://twitter.com/jvq_txt"><img alt="Twitter Follow" src="https://img.shields.io/twitter/follow/jvq_txt?style=social"> </a></p>