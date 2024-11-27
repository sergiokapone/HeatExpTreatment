param (
    [string]$InputDir   # Папка з текстовими файлами
)

function Check-Value {
    param (
        [string]$value,
        [string]$type,
        [string]$time
    )

    if ($value -match '^\d+\.\d+$') {
        return $value
    } else {
        Write-Host "Warning: incorrect $type value for time stamp $time" -ForegroundColor Red
        return $null
    }
}

$OutputFile = "RESULT.csv"
# Спочатку створюємо структуру даних для CSV
$csvData = @()

# Отримуємо всі текстові файли в зазначеній папці
$txtFiles = Get-ChildItem -Path $InputDir -Filter "*.txt"

# Якщо файли не знайдено, виводимо попередження
if ($txtFiles.Count -eq 0) {
    Write-Host "Error: no text files found in the specified folder!" -ForegroundColor Red
    exit 1
}

$flag = $true # Флаг для створення CSV
   
# Проходим по каждому файлу
foreach ($file in $txtFiles) {
    $content = Get-Content $file.FullName
    
    # Розділяємо інформацію

    $time = $file.BaseName.Split('_')[-1] -replace '^0+', ''  # Прибираємо провідні нулі
    $time = if ($time -eq '') { '0' } else { $time }  # Якщо результат порожній, ставимо '0'

    # Забираємо останній елемент після поділу по "_"


    # Діагностика: виводимо вміст файлу і витягнуті дані
    Write-Host "Processing the file -> $($file.Name)"
    Write-Host "File contents:"
    Write-Host $content

    # Ініціалізація змінних для значень
    $avg1 = $null
    $avg2 = $null
    $max = $null
    $min = $null
    $point = $null

    
    # Витягуємо два значення Avg.
    $avgLines = $content | Where-Object { $_ -match '^Avg\.\s*(\d+(\.\d+)?)\s*(°C)?.*$' }
    if ($avgLines.Count -ge 2) {
        $avg1 = ($avgLines[0] -replace 'Avg\.\s*(\d+(\.\d+)?)\s*(°C)?.*$', '$1')
        $avg2 = ($avgLines[1] -replace 'Avg\.\s*(\d+(\.\d+)?)\s*(°C)?.*$', '$1')
    }

    # Витягуємо Max, Min, Point
    $maxLine = ($content | Where-Object { $_ -match '^Max\.\s*(\d+(\.\d+)?)\s*(°C)?.*$' }) -replace 'Max\.\s*(\d+(\.\d+)?)\s*(°C)?.*$', '$1'
    $minLine = ($content | Where-Object { $_ -match '^Min\.\s*(\d+(\.\d+)?)\s*(°C)?.*$' }) -replace 'Min\.\s*(\d+(\.\d+)?)\s*(°C)?.*$', '$1'
    $pointLine = ($content | Where-Object { $_ -match '^\d+\.\d+\s*(°C)?.*$' }) -replace '(\d+(\.\d+)?)\s*(°C)?.*$', '$1'

    # Діагностика: виводимо витягнуті дані
    Write-Host "Time: $time"
    Write-Host "Avg1: $avg1, Avg2: $avg2, Max: $maxLine, Min: $minLine, Point: $pointLine" -ForegroundColor Yellow

    # Перевіряємо, що витягнуті дані є числами
	$avg1 = Check-Value -value $avg1 -type "--AVG1--" -time $time
	$avg2 = Check-Value -value $avg2 -type "--AVG2--" -time $time
	$max = Check-Value -value $maxLine -type "--MAX--" -time $time
	$min = Check-Value -value $minLine -type "--MIN--" -time $time
	$point = Check-Value -value $pointLine -type "--POINT--" -time $time

    # Якщо всі дані коректні, додаємо їх у масив для CSV
    if ($avg1 -and $avg2 -and $max -and $min -and $point) {

        # Створюємо об'єкт із результатами для CSV
        $csvObject = [PSCustomObject]@{
            Time  = $time
            Avg1  = $avg1
            Avg2  = $avg2
            Max   = $max
            Min   = $min
            Point = $point 
        }

        # Додаємо об'єкт у масив
        $csvData += $csvObject
    } else {
        Write-Host "Warning: data not extracted correctly for the time stamp $time" -ForegroundColor Red
        $flag=$false
    }
}

# Якщо $csvData порожній, виводимо повідомлення і припиняємо виконання
if ($csvData.Count -eq 0 -or -not $flag) {
	Write-Host "===================================================================="
    Write-Host "Error: Failed to extract data from files! The CSV file was NOT saved" -ForegroundColor Red
    exit 1
}

# Заголовки для CSV
$csvHeaders = "Time Avg1 Avg2 Max Min Point"

# Додаємо заголовки у файл
$csvHeaders | Out-File -FilePath $OutputFile -Encoding UTF8
# Дописуємо дані
$csvData | ForEach-Object {
    "$($_.Time -f '0.0') $($_.Avg1 -f '0.0') $($_.Avg2 -f '0.0') $($_.Max -f '0.0') $($_.Min -f '0.0') $($_.Point -f '0.0')"
} | Add-Content -Path $OutputFile

Write-Host "===================================="
Write-Host "The CSV file is saved in $OutputFile" -ForegroundColor Green
