#!/bin/bash
BACKUP_BASE="/backup/mongo_backups"
DATE=$(date +%F)
MONGOS_HOST="172.24.7.37"
MONGOS_PORT="27027"
CONFIG_SERVERS=("172.24.7.37" "172.24.7.38" "172.24.7.39")
CONFIG_PORT=27019
mkdir -p $BACKUP_BASE
echo "[$(date)] Starting MongoDB backup..."
mongodump --host $MONGOS_HOST --port $MONGOS_PORT --out $BACKUP_BASE/mongodump-$DATE
if [ $? -ne 0 ]; then echo "ERROR: mongodump of shard data failed!"; exit 1; fi
for SERVER in "${CONFIG_SERVERS[@]}"; do
  mongodump --host $SERVER --port $CONFIG_PORT --out $BACKUP_BASE/config_backup_$SERVER-$DATE
  if [ $? -ne 0 ]; then echo "ERROR: mongodump of config server $SERVER failed!"; exit 1; fi
done
tar -czf $BACKUP_BASE/mongodump-$DATE.tar.gz -C $BACKUP_BASE mongodump-$DATE
for SERVER in "${CONFIG_SERVERS[@]}"; do
  tar -czf $BACKUP_BASE/config_backup_$SERVER-$DATE.tar.gz -C $BACKUP_BASE config_backup_$SERVER-$DATE
done
rm -rf $BACKUP_BASE/mongodump-$DATE
for SERVER in "${CONFIG_SERVERS[@]}"; do
  rm -rf $BACKUP_BASE/config_backup_$SERVER-$DATE
done
echo "Backup completed successfully at $BACKUP_BASE"
