#!/bin/bash

# Since we are taking a physical backup of the mysql files, we do NOT want the DB container
#   running when we update our local files

# stop Docker containers (database and Moodle php)
/usr/local/bin/docker-compose down

# update files from backup
sudo rsync --delete --progress -avi -e"ssh -i /home/moodle_backup/.ssh/id_rsa" moodle_backup@db3.midmich.edu:/path/to/backup/directory/mysql/ /var/moodle/mysql/

# start Docker containers
/usr/local/bin/docker-compose up -d
