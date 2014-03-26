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
DROP TABLE IF EXISTS dayline;
DROP INDEX IF EXISTS uni_dayline;
CREATE TABLE IF NOT EXISTS dayline(sn INTEGER, date DATE, open INTEGER, high INTEGER, low INTEGER, close INTEGER, count INTEGER, total INTEGER);
.separator " "
.import $dump dayline
CREATE UNIQUE INDEX uni_dayline on dayline(sn, date);
CREATE TABLE IF NOT EXISTS macd(sn INTEGER, date DATE, di INTEGER, ax INTEGER, diax INTEGER, dibx INTEGER, difINTEGER, macd INTEGER);
-EOF-

#insert into min_date select sn, min(date)  from dayline group by sn;

