#!/usr/bin/env bash
#
# Create access_log table in the default database.
#
TABLE=access_log
SQL_CREATE_TABLE="
create external table if not exists $TABLE (
  time string,
  host string,
  user string,
  method string,
  path string,
  code int,
  size int,
  referer string,
  agent string
)
COMMENT 'Access Log Realime'
PARTITIONED BY (dt string, th string)
ROW FORMAT DELIMITED
   FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/tmp/$TABLE';
"

echo "create '$TABLE' table in default database"
hive -e "$SQL_CREATE_TABLE; describe $TABLE;"

echo "create partitions for $TABLE"
current_date=$(date +'%Y%m%d')
add_patitions=
i=0
while [ $i -lt 24 ]; do
  add_patitions="${add_patitions}alter table $TABLE add partition (dt = $(date +'%Y%m%d'), th = $(printf "%02d" $i));"
  i=$((i+1))
done
hive -e "$add_patitions"
