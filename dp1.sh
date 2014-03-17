#! /bin/bash


if [ $# -ne 1 ]; then
    echo "Usage: $# $(basename $0) file_path"
    exit 1
fi

tail -n+5 $1 | awk  '{print "INSERT INTO stock(name, sn) VALUES(\x27"$1"\x27,", "\x27"$11"\x27);"}';

