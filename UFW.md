# Mémo pour UFW

L'installation de UFW

```
sudo ufw allow ssh
sudo ufw allow 9090
sudo ufw allow "WWW Full"
```

Lister les rôles activer

```
sudo ufw status numbered
sudo ufw delete [NUMERO]
```

(Dés)Activer UFW

```
sudo enable ufw
sudo disable ufw
```