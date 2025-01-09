#!/bin/bash

## Mises à jour du système
sudo apt update && sudo apt full-upgrade -y

## LAMP installation (PHP Nextcloud)
sudo apt install apache2 mariadb-server php php-gd php-mbstring php-xml php-zip php-curl php-mysql -y

## Système
sudo systemctl enable --now apache2 mariadb
sudo mysql_secure_installation