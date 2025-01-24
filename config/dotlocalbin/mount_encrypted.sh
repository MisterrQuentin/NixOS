#!/usr/bin/env bash

sudo cryptsetup luksOpen /dev/md126p4 crypted-newvol
sudo mount /dev/mapper/crypted-newvol ~/Encrypted-Cloud

