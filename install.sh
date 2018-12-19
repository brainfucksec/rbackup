#!/bin/sh

# rbackup installation file
#
# install - install a program, script, or datafile
# Don't run this script as a root!
#
# Copyright (C) 2018 Brainfuck
#
# This script is compatible with the BSD install script, but was written
# from scratch.  It can only install one file at a time, a restriction
# shared with many OS's install programs.


set -euo pipefail

PROG_NAME="rbackup"
VERSION="0.1.5"
PROG_DIR="$HOME/bin"
DATA_DIR="$HOME/.config"


mkdir -pv "$PROG_DIR"
mkdir -pv "$DATA_DIR/$PROG_NAME"
install -Dm644 -v data/* "$DATA_DIR/$PROG_NAME"
install -Dm755 -v rbackup.sh "$PROG_DIR/$PROG_NAME"
