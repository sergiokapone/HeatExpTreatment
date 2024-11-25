param (
    [string]$csvFile,
    [string]$excelFile
)

# Читання вмісту CSV файлу
$fileContent = Get-Content $csvFile

# Замінюємо всі послідовності пробілів на один пробіл
$processedContent = $fileContent -replace '\s+', ' ' -replace '\.', ','

# Тимчасовий файл для обробки
$processedCsvFile = "$env:TEMP\processed.csv"

# Записуємо оброблений текст у новий файл
$processedContent | Set-Content -Path $processedCsvFile

# Створюємо COM-об'єкт для Excel
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false  # Можно установить $true для видимости Excel

# Створюємо новий робочий аркуш
$workbook = $excel.Workbooks.Add()
$worksheet = $workbook.Sheets.Item(1)

# Імпортуємо дані з обробленого CSV з пропуском як роздільник
$queryTable = $worksheet.QueryTables.Add("TEXT;$processedCsvFile", $worksheet.Range("A1"))

# Налаштуємо параметри для роздільника пробілу
$queryTable.TextFileSpaceDelimiter = $true
$queryTable.TextFileTabDelimiter = $false
$queryTable.TextFileCommaDelimiter = $false
$queryTable.TextFileSemicolonDelimiter = $false

# Вказуємо, що всі стовпці - текстові (щоб не було інтерпретації як дата)
$queryTable.TextFileColumnDataTypes = 1, 1, 1, 1, 1, 1  # 2 - означає текстовий формат для всіх стовпців

# Оновлюємо таблицю
$queryTable.Refresh()


# Перетворюємо текстові значення на числа (для стовпців, де це необхідно)
foreach ($cell in $worksheet.UsedRange.Cells) {
    if ($cell.Value -match '^\d+\,\d+$') {
        $cell.Value = [double]$cell.Value
        $cell.NumberFormat = "0,0.0"  # Формат числа с одним знаком после запятой
    }
}

# Налаштуємо формат чисел з одним десятковим знаком (наприклад, 20.0 відображатиметься як 20,0)
foreach ($cell in $worksheet.UsedRange.Cells) {
    if ($cell.Value -match '^\d+\,+\d{1}$') {
        $cell.NumberFormat = "0,0.0"  # Формат числа с одним знаком после запятой
    }
}

# Зберігаємо в Excel файл
$workbook.SaveAs($excelFile)

# Закриваємо Excel
$excel.Quit()

# Звільняємо COM об'єкти
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null

# Видаляємо тимчасовий файл
Remove-Item -Path $processedCsvFile
