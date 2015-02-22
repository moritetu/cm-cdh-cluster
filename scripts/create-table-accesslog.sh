#!/usr/bin/env bash
#
# Create access_log table in the default database.
#
SQL_CREATE_TABLE="
create external table if not exists access_log (
  time string,
  message string
)
COMMENT 'Access Log Realime (json data)'
ROW FORMAT DELIMITED
   FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/tmp/access_log';
"

echo "create 'access_log' table in default database"
hive -e "$SQL_CREATE_TABLE; show tables;"
