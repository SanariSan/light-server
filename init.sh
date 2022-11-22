#!/bin/bash

docker build -t light-server .
docker run -d --rm --name light-server -p 80:80 light-server