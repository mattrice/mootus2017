#! /bin/bash

# This directory should be writable by the user executing the script
# If the directory does not exist, an attempt will be made to create it
local_dirpath='/var/moodle/completed/'

# If a 'completed' file exists in the backup directory, pull the files
# This assumes that the script doing the database backup creates this file when the DB backup is ready
last_completed=`ssh moodle_backups@db3.midmich.edu ls /path/to/backup/directory/mysql/*completed`

last_status=$?

# use bash operators to get just the filename
# e.g. use a greedy glob matcher to remove everything (including) the right-most forward slash
# http://tldp.org/LDP/LG/issue18/bash.html
filename=${last_completed##*/}

if [ 0 != "$last_status" ]
then
    # If the ls-over-ssh call failed for some reason, abort
    # echo $(date) "mysql3 ssh call failed with code ${last_status} - aborting"
    exit "$last_status"
fi

# Keep track of which backups have been brought locally
if [ -e "${local_dirpath}${filename}" ]
then
    # Output if verbosity is high enough?
    # echo $(date) "sync already completed - aborting"
    exit 0
else
    echo
    echo $(date) "new files to sync detected - starting"

    # Do DB sync
    /path/to/sync/scripts/database_sync_wrapper.sh

    if [ ! -d "$local_dirpath" ]
    then
        mkdir -p "$local_dirpath"
    fi

    # Write $filename to $local_dirpath so that we know the files have been synced already
    touch "${local_dirpath}${filename}"
    echo "sync finished"
fi
