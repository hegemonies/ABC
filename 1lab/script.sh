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
ifconfig | egrep -o 'enp([0-9])s([0-9])'
ifconfig | grep 'ether' | awk '{print $2}'

#ifconfig | grep -o 'lo'
#ifconfig | egrep -o 'virbr([0-9])'
