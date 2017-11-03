#! /bin/bash

logfile='/var/log/moodle_backup.log'
pidfile='/tmp/rsync_cron.pid'

# Hash the currently running PID to get a signature for this run
run_hash=`echo $$ | md5sum -`
run_ident="${run_hash:0:10}"

# Use ANSI colors in log output
colors=(39 31 32 33 34 35 36)
# Get the minute (+%M => 00..59) or hour (+%H => 00..23) of the current time
# strip out any leading 0s (e.g. 10#)
# take the modulo (% 7 = the length of the colors array)
cindex=$((10#`date +%H` % 7))
color=${colors[cindex]}

echo -e $(date) "[\e[${color}m$run_ident\e[0m] starting moodledata rsync" >> "$logfile"

flock --nonblock --conflict-exit-code 70 "$pidfile" /path/to/sync/scripts/moodle_sync/data_sync.sh

last_status=$?
if [[ 0 != "$last_status" ]]; then
    if [[ 70 != "$last_status" ]]; then
        echo
        echo $(date) "finished moodledata rsync (rsync error code $last_status)"
        echo -e $(date) "[\e[${color}m$run_ident\e[0m] finished moodledata rsync (rsync error code $last_status)" >> "$logfile"

    else
        echo -e $(date) "[\e[${color}m$run_ident\e[0m] terminating moodledata rsync (could not acquire lock)" >> "$logfile"
    fi
else
    echo
    echo $(date) "finished moodledata rsync"

    echo -e $(date) "[\e[${color}m$run_ident\e[0m] finished moodledata rsync" >> "$logfile"
fi

