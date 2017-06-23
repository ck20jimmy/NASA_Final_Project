#!/bin/bash
str=$(sudo tcpdump -nn -c 5 "port 53 and dst 192.168.1.1" | awk '{print $3}'| cut -d '.' -f -4 | sort | uniq -c | awk '{print $2,$1}')
#echo $str
cnt=0
len=3
while [ $cnt -lt 5 ]
do
		if [ $cnt -eq 0 ]; then
			st1=$(echo $str | cut -d ' ' -f -2)
			str=$(echo $str | cut -d ' ' -f 3-)
		#echo st1
		echo $st1
			var=$(echo $st1 | awk '{print $2}')
		#	echo var
		#	echo $var
			if [ $var -ge 2 ]; then
				ip=$(echo $st1 | awk '{print $1}')
				#echo "${ip} is probably spoofing" >> attack
				#echo "spoofing ip and count : ${ip} ${var}"
				echo "${ip} ${var}">>attack
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
			if [ $var -ge 2 ]; then
					ip=$(echo $st1 | awk '{print $1}')
				#	echo "${ip} is probably spoofing"
				#	echo "spoofing ip and count : ${ip} ${var}"
				echo "${ip} ${var}" >> attack
			fi
		#	echo var
		#	echo $var
			cnt=`expr $cnt + $var`
		#	echo cnt
		#	echo $cnt	
		fi
done
