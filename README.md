# Setup
## The backup server
### Server specs

* Ubuntu 16.04 (VM running on top of ESXi 6.5.0 build 5310538)
* 4 CPU
* 12G RAM
* 1000G HDD space

### Server configuration

* Docker CE (version 17.09.0\~ce-0\~ubuntu)
* Docker Compose (version 1.16.1, build 6d1ac21)
* A dedicated user: `moodle_backup` (in the `docker` group)
* Passwordless SUDO to run rsync (we have found that running as the superuser on the receiver allows for better coping with users/groups/permissions)
    ```
    # /etc/sudoers.d/rsync
    moodleback ALL=(root) NOPASSWD: /usr/bin/rsync
    ```

* Jobs in cron (e.g. `sudo crontab -u moodle_backup -e`) that support 1) periodically pulling new Moodledata files and 2) checking to see whether a new database backup is ready to pull

    * Sync new Moodledata files every hour
        ```
        0 * * * * cd /path/to/sync/scripts/ && ./moodledata_sync_wrapper.sh
        ```

    * Check for a new database backup
        ```
        * * * * * cd /path/to/sync/scripts/ && flock --nonblock /tmp/signal.pid ./signal.sh
        ```

## Moodledata
The backup server needs access to Moodle's file repository (Moodledata). In our setup, this is done via rsync/passwordless ssh to a server named **content.midmich.edu** (see [moodledata_sync.sh](moodledata_sync.sh) for the command) with the (local) `moodle_backup` user on `content.midmich.edu` in the `www-data` group (Moodledata permissions are set to 0777, but having the user in `www-data` would support permissions of 0750).

## Database
The backup server needs access to the database backup (see [db3_database_backup.sh](db3_database_backup.sh) for one such example script). This is accomplished via rsync/passwordless ssh to a server named **db3.midmich.edu** (see [database_sync.sh](database_sync.sh) for the command) in our case that means adding the (local) `moodle_backup` user on `db3.midmich.edu` to the `root` group.

## PHP Code
The backup server needs access to a container to run Moodle. This is accomplished through [Gitlab's Docker container repository](https://docs.gitlab.com/ce/user/project/container_registry.html). The production Moodle container (approximated by [Dockerfile_moodle_base](Dockerfile_moodle_base)) is used as a starting point for the backup node: essentially additional config is added to Moodle's `config.php` (see [Dockerfile_moodle_backup](Dockerfile_moodle_backup) for the syntax). Additionally, a new [ENTRYPOINT script](moodle_entrypoint.sh) was written to automatically change some database settings when the Moodle container starts up.
