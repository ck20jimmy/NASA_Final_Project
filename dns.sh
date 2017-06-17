#!/bin/bash

# dns security DDos
# 避免ip大量查詢癱瘓dns
# 作法：tcpdump過濾封包，50封包內有35封包來自一個ip就警告
#	40封包來自同ip就先封鎖

#取得封包數量並把它排序紀錄每個ip查了幾次，為了方便先取5個封包，超過3個來自同ip警告
str=$(sudo tcpdump -nn -c 50 port 53 | awk '{print $3}'| cut -d '.' -f -4 | sort | uniq -c | awk '{print $2,$1}')
cnt=0
len=3
while [ $cnt -lt 50 ]						#cnt檢查總共檢驗了幾個封包
do
		if [ $cnt -eq 0 ]; then				#第一次找因為有一些雜物所以分開寫
			st1=$(echo $str | cut -d ' ' -f -3)	#去掉雜物
			str=$(echo $str | cut -d ' ' -f 4-)	#st1:一組ip和他的查詢次數
		#	echo st1				#var:查詢次數
			echo $st1
			var=$(echo $st1 | awk '{print $3}')
		#	echo var
		#	echo $var
			if [ $var -ge 35 ]; then
				ip=$(echo $st1 | awk '{print $2}')
				echo "${ip} is probably spoofing"
			fi
			cnt=`expr $cnt + $var`
		#	echo cnt
		#	echo $cnt
		else
			st1=$(echo $str | cut -d ' ' -f -2)
		#	echo st1
			str=$(echo $str | cut -d ' ' -f 3-)
			echo $st1
			var=$(echo $st1 | awk '{print $2}')
			if [ $var -ge 35 ]; then
					ip=$(echo $st1 | awk '{print $1}')
					echo "${ip} is probably spoofing"
			fi
		#	echo var
		#	echo $var
			cnt=`expr $cnt + $var`
		#	echo cnt
		#	echo $cnt	
		fi
done
