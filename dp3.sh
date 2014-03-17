#! /bin/bash

# convert dayline files of TDX into the data that can be imported into database
program=$(basename $0)
 if [ $# != 1 ]; then
 	echo "Usage: $program day_data_dir"
	exit 1
 fi

for i in $(ls $1); do
	suffix=${i:8}
	if [ "$suffix" == ".TXT" ]; then
		j=${i:2}
		iconv -f cp936 -t utf8 $1/$i|head -n-1|tail -n+3|awk -v sn=${j%%.*}  '{
			split($1, a, "/", seps)
			$2=$2*100
			$3=$3*100
			$4=$4*100
			$5=$5*100
			$7=($7*1000)/1000
			print sn, a[3]a[1]a[2], $2, $3,$4,$5,$6,$7
		}'
	fi
done
