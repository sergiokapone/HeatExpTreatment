set fit quiet

print ARG1

# Используем переменные для файла данных и выходного изображения
filename = ARG1
outputfile = ARG2

# Настраиваем вывод
set terminal pdf
set output outputfile

# Задаем параметры графика
set title "Plot Temperature Values vs Time"
set xlabel "Time, s"
set ylabel "Temperatures, °C"

# Устанавливаем формат осей
set format x "%.0f"
set format y "%.0f"

# Включаем сетку
set grid
set xtics 90


# Устанавливаем разделитель в файле (запятая)
set datafile separator whitespace

# Задаем легенду
set key outside top right

# Построение графиков
plot filename using 1:2 title "Avg1" w lp, \
     filename using 1:3 title "Avg2" w lp, \
     filename using 1:4 title "Max" w lp, \
     filename using 1:5 title "Min" w lp, \
     filename using 1:6 title "Point" w lp
     # filename using 1:4 title "Point" with linespoints lt 1 lw 2 lc rgb 'yellow' pt 5 ps 1

