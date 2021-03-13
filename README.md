# rbackup

rbackup is a shell script for make encrypted backups with rsync and GnuPG.
This program is created for users of the system, here because the program configuration is based on user home folder (i.e. /home/username/).

Before using this script you need to install (and know) [rsync](https://rsync.samba.org) and [gpg](https://gnupg.org).


## Install
```bash
git clone https://github.com/brainfucksec/rbackup
cd rbackup
chmod +x install.sh
./install.sh
```


## Configuration
To encrypt your backups you need a valid [gpg key](https://www.gnupg.org/gph/en/manual/c14.html#AEN25)

Edit file `~/.config/rbackup/config` with your backup settings (i.e. user data, directories and files to backup), this file is widely commented.

Edit file `~/.config/rbackup/excluderc` with the directories and files to be excluded from the backup, this is the rsync parameter `--exclude-from=FILE`, read the relative entry on rsync manual for more information.

Anyway, in the `/data/examples` folder you will find examples of these files.


## Usage
Start backup:
```bash
rbackup --start
```

Show help menù:
```bash
rbackup --help
```

The better use for this script, is to put in on [crontab](https://www.pantz.org/software/cron/croninfo.html) for periodic backups.


## References:

* [rsync Official Website](https://rsync.samba.org)

* [rsync - Man Page](https://download.samba.org/pub/rsync/rsync.1)

* [GnuPG Official Website](https://gnupg.org/)

* [Linux crontab Command Help and Examples](https://www.computerhope.com/unix/ucrontab.htm)
