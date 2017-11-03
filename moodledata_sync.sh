#!/bin/bash

sudo rsync --progress -avi -e"ssh -i /home/moodle_backup/.ssh/id_rsa" --exclude="tool_heartbeat.test" --exclude="sessions/*" --exclude="cachestore_file/*" moodle_backup@content.midmich.edu:/path/to/moodledata/ /var/moodledata/
