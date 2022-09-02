# rbackup

## Introduction

rbackup is a shell script for making backup of your Linux system with rsync.
Uses `tar gzip` for compression and [GnuPG](https://gnupg.org) for encryption.

This program is a "wrapper" for rsync, then you need to familiarize first with this program, see: [rsync](https://rsync.samba.org), also you need a [gpg key](https://www.gnupg.org/gph/en/manual/c14.html#AEN25) for encrypt the archives.

## Install

For install the program dowload the git repository and run the sh installer present in the git folder:

```bash
git clone https://github.com/brainfucksec/rbackup
cd rbackup
chmod +x install.sh
./install.sh
```

The installer create a `$HOME/bin` folder with a `rbackup` executable and `$HOME/.config/rbackup` folder for the configuration files.

## Configuration

You need to edit the following configuration files for run rbackup:

`~/.config/rbackup/config`

This file is for rsync and backup main settings (i.e. user data, directories and files to backup, external volumes paths).

`~/.config/rbackup/excluderc`

This file is for directories and files to be excluded from backups, used by rsync option `--exclude-from=FILE`.

See: `man rsync` and `rsync --help` for more information.

These files are widely commented, anyway you can find the examples in `/data/examples` folder.

## Usage

For start backup just run the script with `--start` or `-s` option:

```bash
rbackup --start
```

For show the help menù:

```bash
rbackup --help
```

Also you can run this script with [crontab](https://www.pantz.org/software/cron/croninfo.html) for periodic backups, e.g.:

```bash
crontab -e
```

```
# Run rbackup every night at 00:05
05 00 * * * ${HOME}/bin/rbackup --start
```

See: [Linux crontab Command Help and Examples](https://www.computerhope.com/unix/ucrontab.htm)

This script use the following `rsync` default options:

```
--archive, -a            archive mode; equals -rlptgoD (no -H,-A,-X)
--human-readable, -h     output numbers in a human-readable format
--one-file-system, -x    don't cross filesystem boundaries
--info=progress2         show total transfer progress
--log-file=FILE          log what we're doing to the specified FILE
--exclude-from=FILE      read exclude patterns from FILE
```

See: `man rsync` and `rsync --help` for more information.

The completed backups are placed in the `$HOME/.backups` folder.

## References:

* [rsync](https://rsync.samba.org)

* [rsync - Man Page](https://download.samba.org/pub/rsync/rsync.1)

* [GnuPG](https://gnupg.org/)

* [crontab](https://www.pantz.org/software/cron/croninfo.html)

* [crontab.guru](https://crontab.guru/)
