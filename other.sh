# change date format
insert into dayline1 select sn, substr(date,0,5)||'-'||substr(date,5,2)||'-'||substr(date,7,2), open, high, low, close, count, total from dayline;
drop table dayline;
alter table dayline1 rename to dayline;


