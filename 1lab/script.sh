#!/bin/bash
echo "Дата: "$(date)
echo "Имя учетной записи: "$USER
echo "Доменное имя ПК: "$(hostname)

#cpus="$(lscpu | grep 'CPU(s)')"
#lscpu | grep "Имя модели\|Архитектура\|CPU MHz\|Thread(s) per core" 
#printf '%b' "Количество ядер -    "
#echo $cpus | awk '{print $2}'

echo "Процессор:"
printf '  *  %s %b\n' "Модель - $(lscpu | grep 'Model name' | awk '{print $3, $4, $5}')"
printf '  *  %s ' "Архитектура - "
arch="$(lscpu | grep 'Архитектура')"
echo ${arch:12}
printf '  *  %s %b\n' "Тактовая частота - $(lscpu | grep 'Model name' | awk '{print $8}')"
printf '  *  %s %b\n' "Количество ядер - $(lscpu | grep 'CPU(s)' | head -n1 | awk '{print $2}')"
printf '  *  %s ' "Количество потоков на одно ядро - "
arch="$(lscpu | grep 'Потоков на ядро')"
echo ${arch:16}

printf '\n%b\n' "Оперативная память:"
printf '  *  %s %b\n' "Всего - $(free -h | head -n2 | tail -n1 | awk '{print $2}')"
printf '  *  %s %b\n' "Доступно - $(free -h | head -n2 | tail -n1 | awk '{print $4}')"

printf '\n%b\n' 'Жесткий диск'
DF="$(df -h | grep /dev/sda1)"
printf '  *  %b' "  Файловая система - "
echo $DF | awk '{print $1}'
printf '  *  %b' "  Всего - "
echo $DF | awk '{print $2}'
printf '  *  %b' "  Доступно - "
echo $DF | awk '{print $4}'
printf '  *  %b' "  Смонтировано - "
echo $DF | awk '{print $6}'

SWAP="$(swapon | tail -n1)"
printf '  *  %b' '  Swap - '
echo $SWAP | awk '{print $1}'
printf '  *  %b' '  Swap всего - '
echo $SWAP | awk '{print $3}'
printf '  *  %b' '  Swap доступно - '
echo $SWAP | awk '{print $4}'


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

echo "  *  Количество сетевых интерфейсов - "$COUNT_OF_ETH_CON
echo "№ Имя сетевого интерфейса MAC адрес          IP адрес        Скорость соединения"

let "j = 1"

for (( i=0; i < $COUNT_OF_ETH_CON; i++ ))
do
	echo "--------------------------------------------------------------------------------"
	printf '%s ' $j
	#printf '%b' 'Name: '
	let "need_line = ($i * 9) + 1"
	name="$(ifconfig | awk '{print $1}' | head -n$need_line | tail -n1)"
	printf '%s\t\t  ' $name
	
	inet="$(ifconfig | grep 'inet' | awk '{print $2}')"
	#mac="$(ifconfig | grep 'ether' | awk '{print $2}')"
	mac="$(ifconfig | grep 'HWaddr' | awk '{print $5}')"
	
	if [[ $name != "lo" ]]; then
		#printf '%b' 'Mac: '
		echo -n "$(echo $mac | awk -v j="$j" '{print $j}')  "
		#printf '%b ' "$(ifconfig | grep 'HWaddr' | awk '{print $5}' | awk -v j="$j" '{print $j}')"
		let "j += 1"

		#printf '%b' 'Ip: '
		let "need_str = ($i * 2) + 1"
		#echo $inet | awk -v need_str="$need_str" '{print $need_str}'
		#printf '%b\n' "$(ifconfig | grep 'inet' | awk '{print $2}' | awk -v need_str="$need_str" '{print $need_str}')"
		echo -n "$(echo $inet | awk -v need_str="$need_str" '{print $need_str}')  "
	
		#ifconfig $name up >> /dev/random
		speedtest="$(wget -q -O - https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python | tail -n3)"
		printf '%b' 'Down: '
		echo "$(echo $speedtest | awk '{print $2, $3}')"
		printf '\t\t\t\t\t\t\t     %b' 'Up:   '
		echo "$(echo $speedtest | awk '{print $8, $9}') "
	else 
		#printf '%b' 'Ip: '
		let "need_str = ($i * 2) + 1"
		#echo $inet | awk -v need_str="$need_str" '{print $need_str}'
		printf '\t  %b \t\t     ' '-' 
		echo -n "$(echo $inet | awk -v need_str="$need_str" '{print $need_str}')  "
		echo 'Download :( '
		printf '\t\t\t\t\t\t\t     '
		echo 'Upload :('
	fi

done
