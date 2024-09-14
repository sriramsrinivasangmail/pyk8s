#!/usr/bin/env bash

image="localhost:5000/pyk8s:latest"

docker build -t ${image} .
