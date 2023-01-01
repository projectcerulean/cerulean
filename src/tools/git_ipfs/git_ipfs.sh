#!/bin/sh
# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

case $1 in
    clean)  ipfs add --hash=sha2-512 --quieter;;
    smudge) ipfs cat;;
    *)      echo "usage: $0 [clean|smudge]"; exit 1;;
esac
