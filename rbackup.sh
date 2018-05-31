#!/usr/bin/env bash

# rbackup
#
# Shell script for encrypted backups with rsync and GnuPG
#
# Copyright (C) 2018 Brainfuck

# GNU GENERAL PUBLIC LICENSE
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# PATH Environment Variable, needed to avoid rsync errors
export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/$HOME/bin:/$HOME/.bin"

# Program information
readonly prog_name="rbackup"
readonly version="0.1.2"
readonly signature="Copyright (C) 2018 Brainfuck"

# Arguments, arguments num
readonly args="$*"
readonly argnum="$#"

# Date in format: YYYY-mm-dd
readonly current_date="$(date +%Y-%m-%d)"

# Directory of program configuration files
readonly config_dir="$HOME/.config/$prog_name/"

# Load configuration file `~/.config/rbackup/config`
readonly config_file="$config_dir/config"

## Configuration file values
# gpg uid for encryption
readonly user_id=$(awk '/^user_id/{print $3}' "${config_file}")

# Backup file name (label)
readonly label=$(awk '/^label/{print $3}' "${config_file}")

# Directories to backup
readonly source_dir=$(awk '/^source_dir/{print $3}' "${config_file}")

# Directory where put new backups
readonly backup_dir=$(awk '/^backup_dir/{print $3}' "${config_file}")

# Directories in the external volumes to copy new backups
readonly external_dir_1=$(awk '/^external_dir_1/{print $3}' "${config_file}")
readonly external_dir_2=$(awk '/^external_dir_2/{print $3}' "${config_file}")
readonly external_dir_3=$(awk '/^external_dir_3/{print $3}' "${config_file}")
## End of configuration file values

# rsync exclude file
readonly exclude_file="$config_dir/excluderc"

# log file
readonly log_file="$backup_dir/rbackup-$current_date.log"


# Check settings
check_settings() {
    # check dependencies
    declare -a dependencies=('rsync' 'gpg');

    for package in "${dependencies[@]}"; do
        if ! hash "$package" 2>/dev/null; then
            printf "%s\\n" "Error: '$package' is not installed."
            exit 1
        fi
    done

    # check configuration file
    if [[ ! -f "$config_file" ]]; then
        printf "%s\\n" "Error: cannot load configuration file."
    exit 1
    fi

    # check exclude file
    if [[ ! -f "$exclude_file" ]]; then
        printf "%s\\n" "Error: '$exclude_file' not exist."
        exit 1
    fi

    # create backup directory if not exist
    if ! mkdir -pv "$backup_dir"; then
        printf "%s\\n" "Error: cannot create directory for backups."
        exit 1
    fi
}


# Show program version
show_version() {
    printf "%s\\n" "$prog_name $version"
    printf "%s\\n" "$signature"
    printf "%s\\n" "License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>"
    printf "%s\\n" "This is free software: you are free to change and redistribute it."
    printf "%s\\n" "There is NO WARRANTY, to the extent permitted by law."
}


# Show help menù
usage() {
cat << EOF
$prog_name $version
$signature
Encrypted backups with rsync and GnuPG

Usage: $prog_name [command]

Commands:
-h, --help      Show this help menù
-s, --start     Start backup
-v, --version   Show program version
EOF
}


# Start program
main() {
    check_settings

    printf "%s\\n" "$(date +'%Y/%m/%d %T') Backup started" >>"$log_file"

    # Backup with rsync
    #
    # parameters: -rptzhvv --progress --delete --log-file=<file> --exclude-file=<file>
    #
    # -r, --recursive       recurse into directories
    # -p, --perms           preserve permissions
    # -t, --times           preserve modification times
    # -z, --compress        compress file data during the transfer
    # -h, --human-readable  output numbers in a human-readable format
    # -v, --verbose         increase verbosity
    # --progress            show progress during transfer
    # --delete              delete extraneous files from destination dirs
    # --log-file=FILE       log what we're doing to the specified FILE
    # --exclude-from=FILE   read exclude patterns from FILE
    #
    # rsync -h | man rsync for more information

    local filename="backup-$label-$current_date"

    if ! rsync -rptzhvv --progress --delete \
               --log-file="$log_file" \
               --exclude-from "$exclude_file" \
               "$source_dir" /tmp/"$filename"; then
        printf "%s\\n" "Error: rsync backup failed." >>"$log_file"
        exit 1
    fi

    # Compress the backup into a tar.gz archive and copy it to the
    # backup folder
    cd /tmp/ || exit

    if tar -czf "$filename.tar.gz" "$filename"; then
        cp -f "$filename.tar.gz" "$backup_dir"
    else
        printf "%s\\n" "Error: cannot create archive file." >>"$log_file"
        exit 1
    fi

    # Encrypt backup with gpg
    #
    # parameters: --encrypt --cipher-algo <name> --recipient <user>
    #
    # -e, --encrypt             Encrypt data
    # --cipher-algo <name>      Use <name> as cipher algorithm
    # -r, --recipient <name>    Encrypt for user id <name>
    #
    # gpg -h | man gpg for more information
    cd "$backup_dir" || exit

    if ! gpg -e --cipher-algo AES256 -r "$user_id" "$filename.tar.gz"; then
        printf "%s\\n" "Error: GPG encryption failed." >>"$log_file"
        exit 1
    fi

    # Copy encrypted backup to the external volume/s directories
    # if they exist
    if [[ -d "$external_dir_1" ]]; then
        cp "$filename.tar.gz.gpg" "$external_dir_1"
    else
        printf "%s\\n" "Warning: No mounted volumes were found." >>"$log_file"
    fi

    if [[ -d "$external_dir_2" ]]; then
        cp "$filename.tar.gz.gpg" "$external_dir_2"
    fi

    if [[ -d "$external_dir_3" ]]; then
        cp "$filename.tar.gz.gpg" "$external_dir_3"
    fi

    # Delete unnecessary backup files from current and /tmp directory
    rm -f "$filename.tar.gz"
    rm -rf /tmp/backup-*

    # End
    printf "%s\\n" "$(date +'%Y/%m/%d %T') Program successfully terminated" >>"$log_file"
    exit 0
}


# Parse command line options
if [ "$#" == "0" ]; then
    usage
    exit 1
fi

while [ "$#" -gt 0 ]; do
    case "$1" in
        -h | --help)
            usage
            exit 0
            ;;
        -v | --version)
            show_version
            exit 0
            ;;
        -s | --start)
            main
            ;;
        -- | -* | *)
            printf "%s\\n" "Error: invalid option '$1'!" >&2
            printf "%s\\n" "Try '$prog_name --help' for more information."
            exit 1
            ;;
        esac
done

