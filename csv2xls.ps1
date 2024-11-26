param (
    [string]$csvFile,
    [string]$excelFile
)

# Читаємо CSV безпосередньо в масив
$data = Import-Csv -Path $csvFile -Delimiter ' '  # роздільник

# Запускаємо Excel
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false

# Створюємо нову книгу
$workbook = $excel.Workbooks.Add()
$worksheet = $workbook.Sheets.Item(1)

# Записуємо заголовки (імена властивостей) у перший рядок
$row = 1
$col = 1
foreach ($header in $data[0].PSObject.Properties.Name) {
    $worksheet.Cells.Item($row, $col).Value2 = $header
    $col++
}

$worksheet.Range("A1").Resize(1, $col - 1).Interior.Color = 111111255  # Синій колір
$worksheet.Range("A1").Resize(1, $col - 1).Font.Color = 16777215  # Білий колір
# Записуємо дані з масиву в Excel
$row = 2  # Починаємо з другого рядка для даних
foreach ($line in $data) {
    $col = 1
    foreach ($key in $line.PSObject.Properties.Name) {
        $value = $line.$key
        $worksheet.Cells.Item($row, $col).Value2 = [double]$value
        $worksheet.Cells.Item($row, $col).NumberFormat = "0,0"  
        $col++
    }
    $row++
}

# Зберігаємо файл
$workbook.SaveAs($excelFile)

# Закриваємо Excel
$workbook.Close($false)
$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
