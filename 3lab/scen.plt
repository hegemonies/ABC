set terminal png size 500, 350 font 'Verdana, 10'

set output 'result_wtime.png'
plot 'result_wtime.txt' using 1:2 with linespoints lw 1 lt rgb 'red'

set output 'result_ticks.png'
plot 'result_ticks.txt' using 1:2 with linespoints lw 1 lt rgb 'red'

set output 'result_clock.png'
plot 'result_clock.txt' using 1:2 with linespoints lw 1 lt rgb 'red'