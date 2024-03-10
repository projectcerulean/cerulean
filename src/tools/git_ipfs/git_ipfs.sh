#!/bin/sh
# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

IPFS="${IPFS:-ipfs}"

case $1 in
    clean)  "${IPFS}" add --hash=sha2-512 --chunker=size-262144 --quieter;;
    smudge) "${IPFS}" cat;;
    *)      echo "usage: $0 [clean|smudge]"; exit 1;;
esac
