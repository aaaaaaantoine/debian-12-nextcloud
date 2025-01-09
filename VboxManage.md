# Mémo pour gérer ses VM VirtualBox

VBoxManage, parcourir la liste de ces machines virtuelles.

```
VBoxManage list vms
```

Pour afficher les machines virtuelles en cours d’exécution, vous pouvez utiliser la sous-commande.

```
VBoxManage list runningvms
VBoxManage list -l runningvms
```

Lancer une VM.

```
VBoxManage startvm OracleLinux6Test
```

Éteindre correctement la VM précédent lancée.

```
VBoxManage controlvm OracleLinux6Test acpipowerbutton
```

Extinction en mode dégueulasse.

```
VBoxManage controlvm OracleLinux6Test poweroff
```

Lancer sans fenêtrage.

```
VBoxManage startvm OracleLinux6Test --type headless
```

Activer *VirtualDEX Remote Desktop Extension* (VRDE) implémentée dans le package Oracle VM VirtualBox Extension Pack.

```
VBoxManage modifyvm OracleLinux6Test --vrde on
```