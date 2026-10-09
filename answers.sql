Take and Verify a Logical Backup
mkdir -p ~/backups
pg_dump -Fc -f ~/backups/bootcamp.dump bootcamp
pg_restore --list ~/backups/bootcamp.dump | head
createdb bootcamp_check
pg_restore -d bootcamp_check ~/backups/bootcamp.dump

Enable WAL Archiving
wal_level = replica
archive_mode = on
archive_command = 'cp %p /home/$USER/backups/wal/%f'

Simulate a Disaster and Recover

SELECT now();
DELETE FROM students;
restore_command = 'cp /home/username/backups/wal/%f %p'
recovery_target_time = '2025-06-01 10:00:00'

SELECT count(*) FROM students;

Set Up a Streaming Standby

CREATE ROLE replicator
WITH REPLICATION LOGIN PASSWORD 'reppass';

host replication replicator 127.0.0.1/32 md5

pg_basebackup -h 127.0.0.1 -U replicator -D ~/standby -R -P

Watch Replication Health

SELECT application_name, state,
       pg_wal_lsn_diff(sent_lsn, replay_lsn) AS lag_bytes
FROM pg_stat_replication;