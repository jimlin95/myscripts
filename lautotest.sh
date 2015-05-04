#!/bin/bash 
sshpass -p "jenkins" ssh -X -o StrictHostKeyChecking=no jenkins@127.0.0.1 -p 2222
