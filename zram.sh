#!/bin/bash

# vim /etc/systemd/zram-generator.conf
sudo echo "zram-size = ram * 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap" | sudo tee -a /etc/systemd/zram-generator.conf

# reboot
sudo systemctl reboot
