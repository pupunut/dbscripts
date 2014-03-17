#! /bin/bash
export TMPDIR=/var/log

function ct_stock
{
sqlite3  $1 <<- -EOF-
DROP TABLE IF EXISTS stock;
CREATE TABLE stock(
id INTEGER PRIMARY KEY NOT NULL, 
name TEXT NOT NULL,
sn TEXT NOT NULL,
loc INTEGER,
class INTEGER,
UNIQUE (name, sn) ON CONFLICT IGNORE);
-EOF-
}

function ct_trade
{
sqlite3  $1 <<- -EOF-
DROP TABLE IF EXISTS trade;
CREATE TABLE trade(
id INTEGER PRIMARY KEY NOT NULL, 
date DATE NOT NULL,
account INTEGER NOT NULL,
stock INTEGER NOT NULL,
price INTEGER NOT NULL,
count INTEGER NOT NULL,
di INTEGER NOT NULL,
type INTEGER,
fee1 INTEGER NOT NULL DEFAULT 0,
fee2 INTEGER NOT NULL DEFAULT 0,
fee3 INTEGER NOT NULL DEFAULT 0,
fee4 INTEGER NOT NULL DEFAULT 0,
fee5 INTEGER NOT NULL DEFAULT 0,
fee6 INTEGER NOT NULL DEFAULT 0,
trader INTEGER NOT NULL DEFAULT 0,
pos INTEGER,
policy INTEGER,
comment text
);
-EOF-
}

function ct_account
{
sqlite3  $1 <<- -EOF-
DROP TABLE IF EXISTS account;
CREATE TABLE account(
id INTEGER PRIMARY KEY NOT NULL, 
type INTEGER NOT NULL DEFAULT 0,
sn INTEGER NOT NULL,
date DATE,
desc TEXT,
UNIQUE (sn, type) ON CONFLICT IGNORE
);
-EOF-
}

function ct_cashio
{
sqlite3  $1 <<- -EOF-
DROP TABLE IF EXISTS cashio;
CREATE TABLE cashio(
id INTEGER PRIMARY KEY NOT NULL, 
src_acct INTEGER NOT NULL,
dst_acct INTEGER NOT NULL,
date DATE NOT NULL,
value INTEGER NOT NULL,
comment TEXT
);
-EOF-
}

function ct_posio
{
sqlite3  $1 <<- -EOF-
DROP TABLE IF EXISTS posio;
CREATE TABLE posio(
id INTEGER PRIMARY KEY NOT NULL, 
src_pos INTEGER NOT NULL,
dst_pos INTEGER NOT NULL,
date DATE NOT NULL,
comment TEXT,
UNIQUE (src_pos, dst_pos, date) ON CONFLICT IGNORE
);
-EOF-
}

function ct_position
{
sqlite3  $1 <<- -EOF-
DROP TABLE IF EXISTS position;
CREATE TABLE position(
id INTEGER PRIMARY KEY NOT NULL, 
account INTEGER NOT NULL,
status INTEGER NOT NULL,
open_date DATE NOT NULL,
open_trade INTEGER NOT NULL,
close_date DATE,
close_trade INTEGER,
profit INTEGER,
CHECK (status = 1 or (status = 0 AND close_date IS NOT NULL AND close_trade IS NOT NULL AND profit IS NOT NULL))
);
-EOF-
}

function ct_price
{
sqlite3  $1 <<- -EOF-
DROP TABLE IF EXISTS price;
CREATE TABLE price(
stock INTEGER PRIMARY KEY NOT NULL, 
date DATE NOT NULL,
high INTEGER NOT NULL,
low INTEGER NOT NULL,
start INTEGER NOT NULL,
end INTEGER NOT NULL,
comment TEXT,
UNIQUE (stock, date) ON CONFLICT IGNORE
);
-EOF-
}

function ct_profit
{
sqlite3  $1 <<- -EOF-
DROP TABLE IF EXISTS profit;
CREATE TABLE profit(
account INTEGER PRIMARY KEY NOT NULL, 
date DATE NOT NULL,
cash INTEGER NOT NULL,
float_profit INTEGER NOT NULL,
acct_profit INTEGER NOT NULL,
credit_ratio INTEGER NOT NULL DEFAULT 0,
credit_left INTEGER NOT NULL DEFAULT 0,
credit_debt INTEGER NOT NULL DEFAULT 0,
comment TEXT,
UNIQUE (account, date) ON CONFLICT IGNORE
);
-EOF-
}

function create_table
{
    ct_stock || return $?
    ct_trade || return $?
    ct_account || return $?
    ct_cashio || return $?
    ct_posio || return $?
    ct_position || return $?
    ct_price || return $?
    ct_profit || return $?
}

#1: db path
#2: sql file path
function merge
{
sqlite3  $1 <<- -EOF-
PRAGMA cache_size = 1000000;                                                      
PRAGMA synchronous = OFF;                                                        
PRAGMA journal_mode = OFF;                                                       
PRAGMA locking_mode = EXCLUSIVE;                                                 
PRAGMA count_changes = OFF;                                                      
PRAGMA temp_store = MEMORY;                                                      
PRAGMA auto_vacuum = NONE;                                                       
                                                                                    
BEGIN;                                                                           
.read $2
COMMIT;                          
-EOF-
}

#=============
#begin
#=============

if [ $# -ne 1 ]; then
    echo "Usage: $# $(basename $0) dump_dir"
    exit 1
fi

dump_dir=$1

if [ ! -e $1 ]; then
    echo "Can not find dump_dir:$dump_dir"
    exit 1
fi

db="$dump_dir/merge.db"
touch $db
if [ ! -e $1 ]; then
    echo "Can not find dump_db:$db"
    exit 1
fi

echo "Create tables"
create_table $db || exit 1

echo "Start to merge dump files into $db, wait..."

for i in $(ls $dump_dir/*.dump); do 
    merge $db $i || exit 1
done

echo "END"
