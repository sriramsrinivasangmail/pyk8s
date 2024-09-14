#!/usr/bin/env bash

image="localhost:5000/pyk8s:latest"

docker run -it --rm -p 8080:8080 ${image} .
