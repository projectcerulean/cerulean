#!/bin/sh

case $1 in
    clean)  ipfs add --quieter;;
    smudge) ipfs cat;;
    *)      echo "usage: $0 [clean|smudge]"; exit 1;;
esac
