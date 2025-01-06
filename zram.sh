#!/bin/bash
## SWAP = 2 x la capacité de la RAM
sudo echo "zram-size = ram * 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap" | sudo tee -a /etc/systemd/zram-generator.conf

## Redémarrage Système
sudo systemctl reboot
