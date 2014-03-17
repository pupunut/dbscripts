#! /bin/bash


#tail -n+5 2-utf8.txt|awk '{print $3, $4, $5, $8, $10, $11, $12, $13, $14, $15}'

#tail -n+5 $1 | awk  'awk '$10 ~/^[[:alnum:]]+/ {print "INSERT INTO stock(name, sn) VALUES(\x27"$1"\x27,", "\x27"$11"\x27);"}';

if [ 1 -eq 2 ]; then
tail -n+5 2-utf8.txt|awk '{
	switch ($9) {
		case /证券卖出/:
			$9=1
			break
		case /证券买入/:
			$9=2
			break
		case /回购拆出/:
			$9=3
			break
		case /拆出购回/:
			$9=4
			break
		case /证券冻结/:
			$9=5
			break
		case /托管转出/:
			$9=6
			break
		case /股息入账/:
			$9=7
			break
		default:
			switch ($8) {	
				case /银行转存/:
					$8=000
					$9=8
					break
				case /银行转/:
					$8=000
					$9=9
					break
				case /批量利息/:
					$8=0
					$9=10
					break
				default:
					break
				}
	}
	$1=1
	$2=$14
	print $0
}'
fi


tail -n+5 2-utf8.txt|awk '

BEGIN {
	seq = 1
	trade_type["证券卖出"] = seq++
	trade_type["证券买入"] = seq++ 
	trade_type["回购拆出"] = seq++ 
	trade_type["拆出购回"] = seq++ 
	trade_type["证券冻结"] = seq++ 
	trade_type["托管转出"] = seq++ 
	trade_type["股息入账"] = seq++ 
	trade_type["银行转存"] = seq++ 
	trade_type["批量利息"] = seq++ 
}
{
	for (i in trade_type){
		if ($9 ~i)
			$9 = trade_type[i]
		else if ($8 ~i){
			$8 = 0
			$9 = trade_type[i]
		}
	}

	$1=1
	$2=$14
	print $0
}'
