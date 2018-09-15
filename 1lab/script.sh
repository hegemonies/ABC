#!/bin/bash
DATE="$(date)"
echo "Дата: "$DATE
echo "Имя учетной записи: "$USER
HOSTNAME="$(hostname)"
echo "Доменное имя ПК: "$HOSTNAME
lscpu | grep "Имя модели\|Архитектура\|CPU MHz\|Ядер на сокет\|Thread(s) per core" 
printf '\n%b\n' "Оперативная память:"
cat /proc/meminfo | grep "MemTotal"
cat /proc/meminfo | grep "MemFree"
printf '\n%b\n' 'Жесткий диск'
df -HT
printf '\n%b\n' "Сетевые интерфейсы:"

COUNT=0
COUNT_OF_LINE_ETH="$(ifconfig | wc -l)"

if [[ $COUNT_OF_LINE_ETH < 10 ]]; then
	COUNT_OF_ETH_CON=1
else
	let "COUNT_OF_ETH_CON = $COUNT_OF_LINE_ETH / 9"
fi

if [[ $COUNT_OF_LINE_ETH > 18 ]]; then
	let "COUNT_OF_LINE_ETH += 1"
	let "COUNT_OF_ETH_CON += 1"
fi

echo $COUNT_OF_ETH_CON


let "j = 1"
for (( i=0; i < $COUNT_OF_ETH_CON; i++ ))
do

	printf '%b' 'Name: '
	let "need_line = ($i * 9) + 1"
	name="$(ifconfig | awk '{print $1}' | head -n$need_line | tail -n1)"
	echo $name

	#let "need_line = $COUNT_OF_LINE_ETH / ($i + 1)"
	#let "j = $COUNT_OF_ETH_CON"
	#let "need_line = ($j * 9) - 1"
	#let "j -= 1"
	#num="$(ifconfig | tail -n$need_line | head -n8)"
	#echo $num | grep 'inet'

	#printf '%b' 'Ip: '
	#echo $num | awk '{print $7}'
	#echo $num | awk '{print $6}'

	#printf '%b' 'Mac: '
	#echo $num | awk '{print $5}'
	#echo $num | awk '{print $18}'
	
	inet="$(ifconfig | grep 'inet' | awk '{print $2}')"
	mac="$(ifconfig | grep 'ether' | awk '{print $2}')"
	
	printf '%b' 'j = '
	echo $j
	if [[ $name != "lo:" ]]; then
		printf '%b' 'Ip: '
		let "need_str = ($i * 2) + 1"
		echo $inet | awk -v need_str="$need_str" '{print $need_str}'
		
		printf '%b' 'Mac: '
		#let "j = $i + 1"
		echo $mac | awk -v j="$j" '{print $j}'
		let "j += 1"
	
		ifconfig $name up
		printf '%b' 'Download: '
		speedtest="$(wget -q -O - https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python | tail -n3)"
		echo $speedtest | awk '{print $2, $3}'
		printf '%b' 'Upload: '
		echo $speedtest | awk '{print $8, $9}'
	else 
		printf '%b' 'Ip: '
		let "need_str = ($i * 2) + 1"
		echo $inet | awk -v need_str="$need_str" '{print $need_str}'
		printf '%b\n' 'Mac: -'
		echo 'Download: local loop :('
		echo 'Upload: local loop :('
	fi

	echo "----------"
done
