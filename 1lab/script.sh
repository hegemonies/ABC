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
let "COUNT_OF_ETH_CON = $COUNT_OF_LINE_ETH / 9"


for (( i=0; i < $COUNT_OF_ETH_CON; i++ ))
do

	printf '%b' 'Name: '
	let "need_line = ($i * 9) + 1"
	name="$(ifconfig | awk '{print $1}' | head -n$need_line | tail -n1)"
	echo $name

	let "need_line = $COUNT_OF_LINE_ETH / ($i + 1)"
	num="$(ifconfig | tail -n$need_line | head -n8)"

	printf '%b' 'Ip: '
	echo $num | awk '{print $7}'

	printf '%b' 'Mac: '
	echo $num | awk '{print $5}'

	if [[ $name != "lo" ]]; then
		ifconfig $name up
		printf '%b' 'Download: '
		speedtest="$(wget -q -O - https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python | tail -n3)"
		echo $speedtest | awk '{print $2, $3}'
		printf '%b' 'Upload: '
		echo $speedtest | awk '{print $8, $9}'
	else 
		echo 'Download: local loop :('
		echo 'Upload: local loop :('
	fi

	echo "----------"
done