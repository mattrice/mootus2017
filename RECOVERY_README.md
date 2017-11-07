These files should be ready for use (e.g. copy into /var/lib/mysql and set permissions).

HOWEVER it is imperitive that the output of /path/to/log/db3_database_backup.log be checked -
there should be 2 lines like

```
171026 03:19:03 completed OK!
```

One indicating the backup completed successfully, and one indicating preparing the backup
was successful. If either of these `completed OK!` lines is missing, it likely indicates
the backup is NOT READY FOR USE.

If `/etc/mysql/my.cnf` does not exist, it can likely be rebuilt from the configuration
values in `xtrabackup-my.cnf`
