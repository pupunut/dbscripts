#! /bin/bash

program=$(basename $0)
if [ $# != 1 ]; then
 	echo "Usage: $program day_data_dir"
	exit 1
fi

dbdir=$1
db=$dbdir/dayline.db
dump=$dbdir/dayline.dump

set -x

./dp3.sh $dbdir > $dump

sqlite3  $db <<- -EOF-
CREATE TABLE dayline(sn INTEGER, date DATE, open INTEGER, high INTEGER, low INTEGER, close INTEGER, count INTEGER, total INTEGER);
.separator " "
.import $dump dayline
CREATE UNIQUE INDEX uni_stock on dayline(sn, date);
-EOF-

