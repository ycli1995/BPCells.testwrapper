#!/bin/bash -e
wd=$(dirname $(readlink -f $0))

IMAGE=ycli1995/test_bpcells:20231026
docker run -it --rm -e OMP_NUM_THREADS=1 -e OPENBLAS_NUM_THREADS=1 -e PASSWORD=mydocker -v $wd:$wd -w $wd $IMAGE
