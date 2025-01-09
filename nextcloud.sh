#!/bin/bash

## Mises à jour
sudo apt update && sudo apt full-upgrade -y

## Téléchargement de Nextcloud
cd /tmp
sudo wget <https://download.nextcloud.com/server/releases/latest.zip>
sudo unzip latest.zip
sudo mv nextcloud /var/www/html/nextcloud
sudo chown -R www-data:www-data /var/www/html/nextcloud

## Config Nextcloud
sudo nano /etc/apache2/sites-available/nextcloud.conf
sudo a2ensite nextcloud
sudo a2enmod rewrite headers env dir mime
sudo systemctl restart apache2

## UFW Config
sudo apt install -y ufw
sudo ufw allow ssh
sudo ufw allow "WWW Full"
sudo enable ufw

## Réinitialiser le mot de passe admin:
#sudo -u www-data php /var/www/html/nextcloud/occ user:resetpassword admin