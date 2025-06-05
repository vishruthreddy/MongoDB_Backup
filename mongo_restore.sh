#!/bin/bash
BACKUP_BASE="/backup/mongo_backups"
DATE=$1
MONGOS_HOST="172.24.7.37"
MONGOS_PORT="27027"
CONFIG_SERVERS=("172.24.7.37" "172.24.7.38" "172.24.7.39")
CONFIG_PORT=27019
if [ -z "$DATE" ]; then echo "Usage: $0 <YYYY-MM-DD>"; exit 1; fi
echo "[$(date)] Starting MongoDB restore for backups from $DATE..."
for SERVER in "${CONFIG_SERVERS[@]}"; do
  BACKUP_DIR="$BACKUP_BASE/config_backup_$SERVER-$DATE"
  if [ ! -d "$BACKUP_DIR" ]; then echo "Backup folder $BACKUP_DIR does not exist, skipping restore."; continue; fi
  echo "IMPORTANT: Stop mongod on $SERVER before restoring!"
  mongorestore --host $SERVER --port $CONFIG_PORT --drop $BACKUP_DIR
  if [ $? -ne 0 ]; then echo "ERROR: Restore failed for config server $SERVER!"; exit 1; fi
done
SHARD_BACKUP_DIR="$BACKUP_BASE/mongodump-$DATE"
if [ ! -d "$SHARD_BACKUP_DIR" ]; then echo "Shard backup folder not found!"; exit 1; fi
mongorestore --host $MONGOS_HOST --port $MONGOS_PORT --drop $SHARD_BACKUP_DIR
if [ $? -ne 0 ]; then echo "ERROR: Restore failed for shard data!"; exit 1; fi
echo "MongoDB restore completed successfully."
