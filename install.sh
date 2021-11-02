#!/bin/sh

# rbackup installation file
#
# install - install a program, script, or datafile
# Don't run this script as a root!
#
# Copyright (C) 2018-2021 Brainf+ck
#
# This script is compatible with the BSD install script, but was written
# from scratch.  It can only install one file at a time, a restriction
# shared with many OS's install programs.


set -euo pipefail

PROG_NAME="rbackup"
VERSION="0.7.0"
PROG_DIR="$HOME/bin"
DATA_DIR="$HOME/.config"


mkdir -pv "$PROG_DIR"
mkdir -pv "$DATA_DIR/$PROG_NAME"
install -Dm644 -v data/config "$DATA_DIR/$PROG_NAME"
install -Dm644 -v data/excluderc "$DATA_DIR/$PROG_NAME"
install -Dm755 -v rbackup.sh "$PROG_DIR/$PROG_NAME"
