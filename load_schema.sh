#!/bin/bash

cassandra -f -R &

NEXT_WAIT_TIME=5
until (echo 'SELECT * FROM system.peers; ' | cqlsh ) || [ $NEXT_WAIT_TIME -eq 20 ]; do
    sleep $(( NEXT_WAIT_TIME++ ))
done;

echo "SELECT * FROM system.peers; " | cqlsh > /dev/null
if [ $? -ne 0 ]; then
    echo "Cassandra failed to boot"
    exit 1
fi

# Add additional files
for SCHEMA_FILE in /tmp/schema*.cql; do
  cqlsh --request-timeout=30 -f "${SCHEMA_FILE}"
done

# persist rows
nodetool drain
sleep 10
kill -15 %1

wait %1

exit 0
