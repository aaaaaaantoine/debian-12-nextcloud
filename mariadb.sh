1. Connexion à MySQL au compte Root
```
sudo mysql -u root -p
```


2. Création d'une base de donnée 
```
# CREATE DATABASE antoine;
# GRANT ALL ON antoine.* TO 'antoine'@'localhost' IDENTIFIED BY 'Mot De Passe';
# FLUSH PRIVILEGES;
# exit;
```