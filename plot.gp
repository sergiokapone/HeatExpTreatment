set fit quiet

print ARG1

# Використовуємо змінні для файлу даних і вихідного зображення
filename = ARG1
outputfile = ARG2

# Налаштовуємо виведення
set terminal pdf
set output outputfile

# Задаємо параметри графіка
set title "Plot Temperature Values vs Time"
set xlabel "Time, s"
set ylabel "Temperatures, °C"

# Встановлюємо формат осей
set format x "%.0f"
set format y "%.0f"

# Вмикаємо сітку
set grid
set xtics 60


# Встановлюємо роздільник у файлі (пробіл)
set datafile separator whitespace

# Задаємо легенду
set key outside top right

# Побудова графіків
plot filename using 1:2 title "Avg" w lp, \
     filename using 1:3 title "Max" w lp, \
     filename using 1:4 title "Min" w lp, \
     filename using 1:5 title "Point" w lp
     # filename using 1:4 title "Point" with linespoints lt 1 lw 2 lc rgb 'yellow' pt 5 ps 1

