#!/usr/bin/env bash

# ===================================================================
# rbackup
#
# Shell script for make encrypted backups with rsync and GnuPG
#
# Copyright (C) 2018-2020 Brainfuck
#
#
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
# ===================================================================


# Program information
readonly prog_name="rbackup"
readonly version="0.5.0"
readonly signature="Copyright (C) 2018-2020 Brainfuck"

# Initialize arguments
readonly args="$*"
readonly argnum="$#"

# Date in format: `YYYY/mm/dd H:M:S`
# This date format is used for entries in the log file
readonly current_date="$(date +'%Y/%m/%d %T')"

# Directory of configuration files
readonly config_dir="${HOME}/.config/${prog_name}"

# Load configuration file `~/.config/rbackup/config`
readonly config_file="${config_dir}/config"

# Configuration file values:
#
# GPG UID for file encryption
readonly gpg_uid=$(awk '/^gpg_uid/{print $3}' "${config_file}")

# Backup file name (label)
readonly label=$(awk '/^label/{print $3}' "${config_file}")

# Directories to backup
readonly source_dir=$(awk '/^source_dir/{print $3}' "${config_file}")

# Directory where put new backups
readonly backup_dir=$(awk '/^backup_dir/{print $3}' "${config_file}")

# Directories in the external volumes to copy new backups
readonly extdir_1=$(awk '/^extdir_1/{print $3}' "${config_file}")
readonly extdir_2=$(awk '/^extdir_2/{print $3}' "${config_file}")
readonly extdir_3=$(awk '/^extdir_3/{print $3}' "${config_file}")
# End of configuration file values

# Program files:
#
# rsync exclude file
readonly exclude_file="${config_dir}/excluderc"

# log file
readonly log_file="${backup_dir}/rbackup-$(date +'%Y-%m-%d').log"


# ===================================================================
# Write a message in the log file and exit with (1) when an error
# occurs
# ===================================================================
die() {
    # errors and exit statuses will be written to `log_file`
    printf "%s\\n" "${current_date} $@" >>"${log_file}"
    exit 1
}


# ===================================================================
# Check program settings
# ===================================================================
check_settings() {
    # check dependencies
    declare -a dependencies=(rsync gpg);

    for package in "${dependencies[@]}"; do
        if ! hash "${package}" 2>/dev/null; then
            die "Error: '${package}' is not installed."
        fi
    done

    # check configuration file
    if [[ ! -f "${config_file}" ]]; then
        die "Error: cannot load configuration file."
    fi

    # check exclude file
    if [[ ! -f "${exclude_file}" ]]; then
        die "Error: '${exclude_file}' not exist."
    fi

    # create backup directory if not exist
    if ! mkdir -pv "${backup_dir}"; then
        die "Error: cannot create directory for backups."
    fi
}


# ===================================================================
# Show program version
# ===================================================================
show_version() {
    printf "%s\\n" "${prog_name} ${version}"
    printf "%s\\n" "${signature}"
    printf "%s\\n" "License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>"
    printf "%s\\n" "This is free software: you are free to change and redistribute it."
    printf "%s\\n" "There is NO WARRANTY, to the extent permitted by law."
}


# ===================================================================
# Show help menù
# ===================================================================
usage() {
cat << EOF
${prog_name} ${version}
${signature}
Encrypted backups with rsync and GnuPG

Usage: ${prog_name} [command]

Commands:
-h, --help      Show this help menù
-s, --start     Start backup
-v, --version   Show program version
EOF
}


# ===================================================================
# Start program
# ===================================================================
start_backup() {
    check_settings


    # Print information messages on log file
    printf "%s\\n" "${current_date} Backup started" >>"${log_file}"

    printf "%s\\n" "Source directory: ${source_dir}" >>"${log_file}"
    printf "%s\\n" "Backup directory: ${backup_dir}" >>"${log_file}"


    # Backup with rsync:
    #
    # parameters: -azhv --progress --delete --log-file=<file> --exclude-file=<file>
    #
    # --archive, -a            archive mode; equals -rlptgoD (no -H,-A,-X)
    # --compress, -z           compress file data during the transfer
    # --human-readable, -h     output numbers in a human-readable format
    # --verbose, -v            increase verbosity
    # --progress               show progress during transfer
    # --delete                 delete extraneous files from dest dirs
    # --log-file=FILE          log what we're doing to the specified FILE
    # --exclude-from=FILE      read exclude patterns from FILE
    #
    # rsync --help | man rsync for more information

    # set current backup filename
    # for the filenames the date format is `YYYY-mm-dd`
    local filename="backup-${label}-$(date +'%Y-%m-%d')"

    # exec rsync command
    if ! rsync -azhv --progress --delete --log-file="${log_file}" \
               --exclude-from "${exclude_file}" \
               "${source_dir}" /tmp/"${filename}"; then
        die "Error: rsync command failed."
    fi

    # Compress the backup into a tar/gzip archive and copy it to the
    # backup folder
    cd /tmp/ || exit

    if tar -czf "${filename}.tar.gz" "${filename}"; then
        cp -f "${filename}.tar.gz" "${backup_dir}"
    else
        die "Error: cannot create archive file."
    fi

    # Encrypt backup with gpg
    #
    # parameters: --encrypt --cipher-algo <name> --recipient <user>
    #
    # -e, --encrypt             Encrypt data
    # --cipher-algo <name>      Use <name> as cipher algorithm
    # -r, --recipient <name>    Encrypt for user id <name>
    #
    # gpg --help | man gpg for more information
    cd "${backup_dir}" || exit

    if ! gpg -e --cipher-algo AES256 -r "${gpg_uid}" "${filename}.tar.gz"; then
        die "Error: GPG encryption failed."
    fi

    # Copy encrypted backup to the external volume/s directories
    # if they exists
    if [[ -d "${extdir_1}" ]]; then
        cp "${filename}.tar.gz.gpg" "${extdir_1}"
    else
        printf "%s\\n" "${current_date} No external volumes were found, skipping..." >>"${log_file}"
    fi

    if [[ -d "${extdir_2}" ]]; then
        cp "${filename}.tar.gz.gpg" "${extdir_2}"
    fi

    if [[ -d "${extdir_3}" ]]; then
        cp "${filename}.tar.gz.gpg" "${extdir_3}"
    fi

    # Delete unnecessary backup files from current and /tmp directory
    rm -f "${filename}.tar.gz"
    rm -rf /tmp/backup-*

    # End
    printf "%s\\n" "${current_date} Program successfully terminated" >>"${log_file}"
    exit 0
}


# Parse command line arguments and start program
main() {
    if [[ "$#" -eq 0 ]]; then
        usage
        exit 1
    fi

    while [[ "$#" -gt 0 ]]; do
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
                start_backup
                ;;
            -- | -* | *)
                printf "%s\\n" "${prog_name}: Invalid option '$1'!"
                printf "%s\\n" "Try '${prog_name} --help' for more information."
                exit 1
                ;;
        esac
    done
}

main "$@"
