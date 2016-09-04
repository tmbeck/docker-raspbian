#!/bin/bash
# TODO Make this into a Makefile

docker build --tag libjtux .
CID=$(docker create libjtux)
docker cp $CID:/jtux/libjtux.so libjtux.so
docker rm -v $CID

