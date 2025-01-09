# Objectif

L'objectif est de configurer une adresse IP statique sur le serveur Debian Linux.

Veuillez noter que pour les installations de bureau, il est recommandé d'utiliser des outils GUI, tels que `network-manager`. Si vous souhaitez configurer vos interfaces réseau directement via le fichier `/etc/network/interfaces`  sur votre bureau, assurez-vous de désactiver tout autre démon de  configuration réseau pouvant interférer.

Par exemple, les commandes  ci-dessous désactiveront `network-manager` :

```ini
sudo systemctl stop NetworkManager.service
sudo systemctl disable NetworkManager.service
```

# Instructions

##### Activer l'adresse IP statique

Par défaut, vous trouverez la configuration suivante dans le fichier de configuration réseau `/etc/network/interfaces` :

```powershell
sudo nano /etc/network/interfaces
```

```
auto enp0s3 iface
enp0s3 inet static
address 192.168.1.11
netmask 255.255.255.0
gateway 192.168.1.1
```