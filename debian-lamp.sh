#!/bin/bash
sudo apt update && sudo apt full-upgrade -y
sudo apt install apache2 mariadb-server php php-gd php-mbstring php-xml php-zip php-curl php-mysql -y
sudo systemctl enable --now apache2 mariadb
sudo mysql_secure_installation
