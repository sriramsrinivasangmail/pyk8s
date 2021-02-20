#!/bin/bash -e


date
id



mkdir /tmp/home
export HOME=/tmp/home

pip install --user flask 

cd $(dirname $0)
python3 ../src/app.py
