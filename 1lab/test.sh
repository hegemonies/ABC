#tmp="$(swapon | tail -n1)"
#echo ${tmp:0:30} | sed 's/[ *]/\t\t/g' 
#cpus="$(lscpu | grep 'CPU(s)')"
#echo $cpus | awk '{print $2}'


name="$(ifconfig | awk '{print $1}' | head -n26)"
printf '%b' $name
