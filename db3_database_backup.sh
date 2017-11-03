#!/bin/bash
#
# use Percona's xtrabackup utility to backup databases
#
# More info: https://www.percona.com/doc/percona-xtrabackup/2.3/using_xtrabackup/privileges.html#permissions-and-privileges-needed
#
# Assumptions:
# - "$destination" can be read/written by the user executing the script (likely root)
# 
# Example cronjob to run this script
# 15 1 * * * /path/to/backup/script/db3_database_backup.sh > /path/to/log/db3_database_backup.log 2>&1

destination='/path/to/backup/directory/mysql'
dbuser='some_username'
dbpass='some_password'

echo "`date` - starting backup script"

# Remove existing backup directory
if [ -d "$destination" ]
then
    echo -e "\tremoving backup directory: $destination"
    rm -Rf "$destination"
fi

echo -e "\tcreating backup directory: $destination"
mkdir "$destination"

# Make a backup
echo "`date` - starting xtrabackup"

start_file_to_remove="$destination/$( date '+%Y-%m-%d_%H-%M-%S-started-NOT-done' )"
touch "$start_file_to_remove"

# https://www.percona.com/doc/percona-xtrabackup/2.3/xtrabackup_bin/xbk_option_reference.html
# Warning: dashes/hypens (`-`) in database names seem to get escaped e.g. `wordpress@002dblogs` so underscores `_` are preferred!
xtrabackup --backup --user="$dbuser" --password="$dbpass" --target-dir="$destination" --galera-info --databases-file="/path/to/backup/script/databases_to_backup.txt" --skip-version-check

# Check for successful backup (exit code 0)
status=$?
if [ 0 -eq "$status" ]
then
    status="backup completed successfully"
else
    status="backup failed - exited with code $status"
fi

echo "`date` - xtrabackup finished"

echo "`date` - preserving my.cnf parameters into $destination/xtrabackup-my.cnf"

cp /path/to/backup/script/RECOVERY_README "$destination/RECOVERY_README"

# Use sed to translate space-separated config values into line-separated values for easier reading
xtrabackup --print-defaults | sed 's/ --/\r\n--/g' > "$destination/xtrabackup-my.cnf"

echo "`date` - starting prepare"
# Prepare the backup files (so that they can be copied off and used without further processing)
# https://www.percona.com/doc/percona-xtrabackup/2.3/howtos/recipes_xbk_full.html
xtrabackup --prepare --target-dir="$destination" --databases-file="/path/to/backup/script/databases_to_backup.txt"

# touch a new file with timestamp name so we know when the backup is complete
# (also cleanup the file we created when starting the database backup)
touch "$destination/$( date '+%Y-%m-%d_%H-%M-%S-completed' )" && rm "$start_file_to_remove"

# Ensure the files are accessible by `moodle_backup`
# The execute bit is necessary so the `moodle_backup` user can stat the files
chmod -R g+rx "$destination"

echo "`date` - prepare finished"
echo "`date` - $status"
  
