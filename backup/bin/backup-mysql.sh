#!/bin/bash

export LC_ALL=C

days_of_backups=3  # Must be less than 7
backup_owner="backup"
parent_dir="/home/backup/mysql"
defaults_file="/etc/mysql/backup.cnf"
todays_dir="${parent_dir}/$(date +%a)"
log_file="${todays_dir}/backup-progress.log"
#encryption_key_file="${parent_dir}/encryption_key"
now="$(date +%m-%d-%Y_%H-%M-%S)"
#processors="$(nproc --all)"
processors=2

# Use this to echo to standard error
error () {
    printf "%s: %s\n" "$(basename "${BASH_SOURCE}")" "${1}" >&2
    exit 1
}

trap 'error "An unexpected error occurred."' ERR

set_options () {
    mariabackupex_args=(
        "--defaults-file=${defaults_file}"
        "--extra-lsndir=${todays_dir}"
        "--backup"
        "--stream=xbstream"
        "--parallel=${processors}"
    )
    
    backup_type="full"

    # Add option to read LSN (log sequence number) if a full backup has been
    # taken today.
    if grep -q -s "to_lsn" "${todays_dir}/xtrabackup_checkpoints"; then
        backup_type="incremental"
        lsn=$(awk '/to_lsn/ {print $3;}' "${todays_dir}/xtrabackup_checkpoints")
        mariabackupex_args+=( "--incremental-lsn=${lsn}" )
    fi
}

rotate_old () {
    # Remove the oldest backup in rotation
    day_dir_to_remove="${parent_dir}/$(date --date="${days_of_backups} days ago" +%a)"

    if [ -d "${day_dir_to_remove}" ]; then
        rm -rf "${day_dir_to_remove}"
    fi
}

take_backup () {
    # Make sure today's backup directory is available and take the actual backup
    mkdir -p "${todays_dir}"
    find "${todays_dir}" -type f -name "*.incomplete" -delete
    mariabackup "${mariabackupex_args[@]}" "--target-dir=${todays_dir}" \
        2> "${log_file}" \
        | bzip2 > "${todays_dir}/${backup_type}-${now}.xbstream.bz2.incomplete"

    mv "${todays_dir}/${backup_type}-${now}.xbstream.bz2.incomplete" "${todays_dir}/${backup_type}-${now}.xbstream.bz2"
}

#sanity_check && set_options && rotate_old && take_backup
set_options && rotate_old && take_backup

# Check success and print message
if tail -1 "${log_file}" | grep -q "completed OK"; then
    printf "Backup successful!\n"
    printf "Backup created at %s/%s-%s.xbstream\n" "${todays_dir}" "${backup_type}" "${now}"
else
    error "Backup failure! Check ${log_file} for more information"
fi

/usr/bin/touch ${todays_dir}/new.tmp
/usr/bin/rsync -av --delete ${parent_dir}/* rsync://10.0.0.99/backup-mysql
