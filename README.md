# Обробка есперименту по тепловій проникності тіл

## Витягування кадрів та розпізнавання інформації на них

Використовується файл  `frames.ps1` на вхід якому подається відеофайл
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

Для зручності всі скрипти викликались з інтерфейсу `Toal Commander`, в якому створено файл меню `scripts.bar`.


## Для роботи використовувались наступні програми

1. [imagemagick](https://usage.imagemagick.org).
2. [tesseract](https://github.com/tesseract-ocr/tesseract).
3. [gnuplot](http://www.gnuplot.info).
4. [Total Commander](https://www.ghisler.com/index.htm)

Всі скрипти написані на `Powershell`.





