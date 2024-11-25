# Обробка есперименту по тепловій проникності тіл

## Витягування кадрів та розпізнавання інформації на них

Використовується файл  `frames.psq` на вхід якому подається відеофайл
```shell
powershell frames.ps1 videofile
```

На виході утворюється папка з ім'ям файлу з кадрами та текстовими файлами з інформацію з кадрів.

## Створення CSV файлу

Викорисовується файл `csvcreation.ps1` на вхід якого подається папка з кадрами

```shell
powershell csvcreation.ps1 folder
```

## Побудова графіку

За даними CSV файлу за допомогою gnuplot будуємо графік за допомогою скрипта `plot.gp`:

```shell
gnuplot -persist -c  plot.gp input.csv ootput.pdf
```

## Перетворення CSV -> XLSX

Викорисовується файл `csv2xls.ps1` на вхід якого подається CSV файл, а на виході отримуємо XLSX.


## Кнопка в Total Commander

```text
[Buttonbar]
Buttoncount=8
button1=%commander_path%\TOTALCMD.EXE,12
cmd1=%commander_path%\Bars\MainBar.bar
iconic1=0
menu1=Main menu
button2=
iconic2=0
button3=C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe,1
cmd3=powershell -NoExit frames.ps1
param3=%P%N
path3=.
iconic3=0
menu3=frames
button4=C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe,1
cmd4=powershell -NoExit csvcreation.ps1
param4=-InputDir %P
menu4=csvcreation
button5=%COMMANDER_PATH%\TOTALCMD64.EXE,3
cmd5=gnuplot -persist -c  plot.gp
param5=%P%N %P%O.pdf
path5=.
iconic5=0
menu5=plot
button6=C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe,1
cmd6=powershell -NoExit csv2xls.ps1
param6=%P%N %P%O.xlsx
path6=d:\Different\ExpMask\New\
iconic6=0
menu6=csv2xls
button7=shell32.dll,98
cmd7="cmd /k tesseract "
param7=%P%N stdout --psm 6 --oem 3
button8=shell32.dll,98
cmd8=cmd /k magick
param8="%P%N -level 70%%,100%% %P%O_processed.png "
```


## Для роботи використовувались наступні програми

1. [imagemagick](https://usage.imagemagick.org).
2. [tesseract](https://github.com/tesseract-ocr/tesseract).
3. [gnuplot](http://www.gnuplot.info).
4. [Total Commander](https://www.ghisler.com/index.htm)

Всі скрипти написані на `Powershell`.





