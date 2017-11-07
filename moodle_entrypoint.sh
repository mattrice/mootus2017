#!/bin/bash

echo $(date) "starting entrypoint.sh"
# wait for database container to be ready
# https://stackoverflow.com/questions/25503412/how-do-i-know-when-my-docker-mysql-container-is-up-and-mysql-is-ready-for-taking
until nc -z -v -w30 mysql 3306
do
    echo "Waiting for database connection..."
    sleep 5
done

# Update Moodle config
## Automated backup settings
### backup | backup_auto_active => Manual (2)
echo "UPDATE mdl_config_plugins SET \`value\` = 2 WHERE plugin = 'backup' AND \`name\` = 'backup_auto_active';" | mysql --user="$MOODLE_DB_USER" --password="$MOODLE_DB_PASS" --host=mysql "$MOODLE_DB_NAME"


### backup | backup_auto_destination => a local path (for testing; should be set to vault01 for production)
mkdir -p /path/to/moodlecoursebackups
echo "UPDATE mdl_config_plugins SET \`value\` = '/path/to/moodlecoursebackups' WHERE plugin = 'backup' AND \`name\` = 'backup_auto_destination';" | mysql --user="$MOODLE_DB_USER" --password="$MOODLE_DB_PASS" --host=mysql "$MOODLE_DB_NAME"


## Update Site Settings
### fullname and shortname
echo "UPDATE mdl_course SET fullname = '$(date +%Y-%m-%d) backup', shortname = '$(date +%Y-%m-%d) backup' ORDER BY id ASC LIMIT 1;" | mysql --user="$MOODLE_DB_USER" --password="$MOODLE_DB_PASS" --host=mysql "$MOODLE_DB_NAME"


# Purge all caches before run
# Do this after the DB manipulation so that those changes are reflected
php /var/moodle/admin/cli/purge_caches.php

/usr/sbin/apache2ctl -D FOREGROUND
