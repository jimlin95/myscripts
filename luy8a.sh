#!/bin/bash 

sudo docker run --name qci-uy8a --rm -u jim -w /home/jim -i -t -v /home/jim/projects/mtk/uy8a/src:/home/jim/workspace  jimlin95/uy8a-jim /bin/bash 
exit 0
