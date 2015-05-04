#!/bin/bash 
docker run -d --restart=always -p 5000:5000 -v /home/jim/docker_data/registry:/tmp/registry registry:0.9.1
