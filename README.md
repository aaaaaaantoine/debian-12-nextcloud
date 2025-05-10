<div align="center">
<h1 align="center">
<br>Debian Nextcloud Serveur
</h1>
<h3>◦ Développé avec les logiciels et outils ci-dessous.</h3>

<p align="center">
<img src="https://img.shields.io/badge/GNU%20Bash-4EAA25.svg?style&logo=GNU-Bash&logoColor=white" alt="GNU%20Bash" />
<img src="https://img.shields.io/badge/Markdown-000000.svg?style&logo=Markdown&logoColor=white" alt="Markdown" />
</p>
<img src="https://img.shields.io/github/languages/top/aaaaaaantoine/debian-post-install?style&color=5D6D7E" alt="GitHub top language" />
<img src="https://img.shields.io/github/languages/code-size/aaaaaaantoine/debian-post-install?style&color=5D6D7E" alt="GitHub code size in bytes" />
<img src="https://img.shields.io/github/commit-activity/m/aaaaaaantoine/debian-post-install?style&color=5D6D7E" alt="GitHub commit activity" />
<img src="https://img.shields.io/github/license/aaaaaaantoine/debian-post-install?style&color=5D6D7E" alt="GitHub license" />
</div>

---

## 📍 Objectifs

- Mettre à jour son système
- Installation de la de pile LAMP
- Installation de Nextcoud
- Configuration du Virtual Host

---

## 🚀 Mise à jour du système

```sh
apt update && apt full-upgrade
```

---

## 🌍 Installation de la de pile LAMP

LAMP pour Linux, Apache, MariaDB et PHP

```sh
apt install apache2 mariadb-server php php-gd php-mbstring php-xml php-zip php-curl php-mysql -y
systemctl enable --now apache2 mariadb
```

---

## 🔒 MariaDB

- Création d'une base de données MySQL / MariaDB

*Debian est livré par défaut avec le paquet mariadb-server qui est en réalité la version open source de MySQL.*

Une fois effectué, vous devez configurer MySQL très facilement en exécutant la commande:

```sh
mysql_secure_installation
```

Vous pouvez laisser les valeurs par défaut suggérées par l'installateur interactif mais tâchez de définir un mot de passe au compte `root` MySQL.

Création de notre base de donnée MariaDB 

```sh
mysql -u root -p
```

```
CREATE DATABASE test;
GRANT ALL ON antoine.* TO 'test'@'localhost' IDENTIFIED BY 'Mot_De_Passe';
FLUSH PRIVILEGES;
EXIT;
```

---

## 📁 Nextcoud

Nextcloud est un logiciel libre de site d'hébergement de fichiers et une plateforme de collaboration. À l'origine accessible via WebDAV, n'importe quel navigateur web, ou des clients spécialisés, son architecture ouverte a permis de voir ses fonctionnalités s'étendre depuis ses origines.

```
cd /tmp
wget <https://download.nextcloud.com/server/releases/latest.zip>
unzip latest.zip
mv nextcloud /var/www/html/nextcloud
chown -R www-data:www-data /var/www/html/nextcloud
```

---

## 👻 Virtual Host

- Paramétrage du Virtual Host

```sh
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/nextcloud.conf
```

- Editez-le pour le paramétrer de la manière suivante
```sh
vim /etc/apache2/sites-available/nextcloud.conf
```

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

Apache2 vous offre la possibilité d'activer votre fichier de configuration facilement avec la commande embarquée suivante

```sh
a2ensite nextcloud.conf
```

Enfin, redémarrez le service Apache pour prendre en compte votre configuration 

```sh
systemctl restart apache2
```

En toute logique, votre application est dorénavant accessible depuis l'interface HTTP de votre serveur.
