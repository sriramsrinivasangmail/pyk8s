#!/bin/bash

cd $(dirname $0)
docker rm -f pyhttp; docker run --name pyhttp -d --user 1001 -p 8080:8080 quay.io/bitnami/python:3.8 /bin/bash -c "cd /tmp; git clone https://github.com/sriramsrinivasangmail/pyk8s.git && pyk8s/bin/start.sh"
