#!/bin/bash


each_ip=$(cat attack | sort |uniq )
count_each_ip=$( cat attack | sort |uniq -c )

#echo $count_each_ip

all_loc=''
for ip in $each_ip
do
	#echo $ip
	tmp=$(geoiplookup -f /usr/share/GeoIP/GeoLiteCity.dat "$ip") 
	
	#get loc
	loc=$( echo "$tmp" | awk '{print $6}' \
		| cut -d ',' -f 1
	)
	if [ "$loc" == "IP" ]; then
		loc="Undefined"
	fi
	all_loc=$all_loc'\n'$loc
	
	#get lat and long
	lat=$( echo "$tmp" | awk '{print $11}' | cut -d ',' -f 1)
	if [ "$lat" == "" ]; then
		lat=Undefined
	fi
	lng=$( echo "$tmp" | awk '{print $12}' | cut -d ',' -f 1)
	
	if [ "$lng" == "" ]; then
                lng=Undefined
        fi

	#echo $ip' '$loc''$lat' '$lng >> ip_to_loc
done

#echo -e $all_loc

count=$( echo -e ${all_loc:2} | grep -v 'Undefined'| sort | uniq  -c )

#echo -e ${all_loc:2} | grep -v 'Undefined' | sort

IFS='\n'

line=$(echo "$count" | wc -l )

#echo $count | awk 'FNR == 1 {print}'

#echo  $count | awk '{print $1}'

#echo $count

#write to json
echo "[{\"data\":{" > ipdata.json

for ((i=1; i<=${line}; i=i+1))
do
	fre=$( echo $count | awk -v j=$i 'FNR == j {print $1}' )
	country=$( echo $count | awk -v j=$i 'FNR == j {print $2}' )
	
	fill=''
	if [ $fre -ge 30 ]; then
		fill='High'		
	elif [ $fre -le 10 ]; then
		fill='LOW'
	else
		fill='Medium'
	fi
	
	if [ $i -eq 1 ]; then
		echo "\"$country\"" ":{\"fillKey\": "\"$fill\"", \"attack\": $fre}" >> ipdata.json
	else
		echo ",\"$country\"" ":{\"fillKey\": "\"$fill\"", \"attack\": $fre}" >> ipdata.json
	fi
done

echo "}}," >> ipdata.json


#write ip and frequency

echo "{\"data2\":[" >> ipdata.json

fre=$(echo $count_each_ip | awk 'FNR == 1{print $1}')
ip=$(echo $count_each_ip | awk 'FNR == 1{print $2}')

echo "{\"ip\":\"$ip\",\"attack\":$fre}" >> ipdata.json

line=$(echo "$count_each_ip" | wc -l)

for ((i=2; i<=${line}; i=i+1))
do
	fre=$(echo $count_each_ip | awk -v j=$i 'FNR == j{print $1}')
	ip=$(echo $count_each_ip | awk -v j=$i 'FNR == j{print $2}')
	
	
	country=$( echo $count_each_ip | awk -v j=$i 'FNR == j {print $2}')
	country=$( geoiplookup -f /usr/share/GeoIP/GeoLiteCity.dat "$country" )
	country=$( echo "$country" | awk '{print $6}' \
                | cut -d ',' -f 1 )
	
	if [ "$country" == "IP" ];then
		country="undefined"
	fi
	
	if [ $i -eq 1 ]; then
		echo "{\"ip\":\"$ip\",\"attack\":$fre,\"country\":\"$country\"}" >> ipdata.json
	else
		echo ",{\"ip\":\"$ip\",\"attack\":$fre,\"country\":\"$country\"}" >> ipdata.json
	fi

done

echo "]}]" >> ipdata.json
