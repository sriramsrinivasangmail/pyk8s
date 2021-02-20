#!/bin/bash

cd $(dirname $0)
docker rm -f pyhttp; docker run --name pyhttp -d --user 1001 -p 8080:8080 -v ${PWD}/bin:/mnt/bin -v ${PWD}/src:/mnt/src quay.io/bitnami/python:3.8 /mnt/bin/start.sh
