#!/bin/bash -e


date
id
me=$(id -u)

mkdir /tmp/home
export HOME=/tmp/home

pip install --user flask 

python3 /mnt/src/app.py
