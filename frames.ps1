param (
    [string]$InputVideo
)



# Перевіряємо, чи вказано вхідний файл
if (-Not $InputVideo -or -Not (Test-Path $InputVideo)) {
    Write-Host "Error: Specify an existing video file." -ForegroundColor Red
    exit 1
}

# Витягуємо ім'я файлу без розширення
$inputFileName = [System.IO.Path]::GetFileNameWithoutExtension($InputVideo)

# Вказуємо папку для вихідних кадрів


$OutputDir = [System.IO.Path]::GetFileNameWithoutExtension($InputVideo)


# Перевіряємо, чи існує папка
if (Test-Path -Path $OutputDir ) {
    Write-Host "Folder '$OutputDir ' exists, remove it..."
    Remove-Item -Path $OutputDir -Recurse -Force
} else {
    Write-Host "Folder '$OutputDir' was not found, no deletion required."
}


if (-Not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# Формуємо шлях для виведення, додаючи ім'я вихідного файлу
$OutputFilePattern = "$OutputDir\$inputFileName" + "_%04d.png"

# Витягуємо кадри з тимчасовими мітками в іменах
ffmpeg -i $InputVideo -hide_banner -loglevel error -vf "select=not(mod(n\,1))" -vsync vfr -frame_pts 1 "$OutputFilePattern"

# Отримуємо кількість кадрів у відео
$frameFiles = Get-ChildItem "$OutputDir\*.png" | Sort-Object CreationTime  # Сортуємо за часом створення


# Перейменовуємо кадри з додаванням часу в імені
$frameIndex = 0
foreach ($frame in $frameFiles) {
    # Починаємо з індексу 0 для першого кадру

    $frameIndex++
    
    # Формуємо часову мітку з трьома знаками
    $Time = $frameIndex * 30 - 30  # Це дасть 0, 30, 60 і т.д.
    $TimePadded = "{0:D4}" -f $Time

    # Формуємо нове ім'я файлу з тимчасовою міткою
    $NewName = "P_" + $inputFileName + "_$TimePadded.png"
    
    $NewPath = [System.IO.Path]::Combine((Resolve-Path $OutputDir).Path, $NewName)

    # Діагностика

    $frameName = [System.IO.Path]::GetFileName($frame)
    Write-Host "Processing file -> $frameName"
    Write-Host "New name: $NewName"
    Write-Host "Full path: $NewPath"

    # Перейменовуємо файл
    Rename-Item -Path $frame.FullName -NewName $NewPath
}

Write-Host "== Processing PNG files with Tesseract =="

# Проходимо по кожному PNG файлу і розпізнаємо текст
Get-ChildItem "$OutputDir\*.png" | ForEach-Object {
    $ImagePath = $_.FullName
    $TextOutputPath = "$OutputDir\$($_.BaseName)"
    $TempImagePath = "$OutputDir\temp_$($_.BaseName).png"  # Тимчасовий файл для обробленого зображення

    # Діагностика
    $ImagePathName = [System.IO.Path]::GetFileName($ImagePath)
    Write-Host "==============================" -ForegroundColor Yellow
    Write-Host "Processing image -> $ImagePathName"
    # Write-Host "OCR text in: $TextOutputPath"
    
    # Виконання магії з використанням ImageMagick для зміни рівня яскравості
    & magick "$ImagePath" -threshold 96% "$TempImagePath"

    # Виконання tesseract на тимчасовому файлі
    & "tesseract.exe" "$TempImagePath" "$TextOutputPath" --psm 6 --oem 3

    # Видаляємо тимчасовий файл
    Remove-Item "$TempImagePath" -Force

    # Діагностика
    # Write-Host "Temporary file deleted: $TempImagePath"
}

# Визначаємо список заборонених символів
$blacklist = '["\)\(—\\\+\]\[»,\*\-_~=<>!@$|”“™bdefhjklopqrstuwz]'

# Go through each text file in the folder
Get-ChildItem "$OutputDir\*.txt" | ForEach-Object {
    $TextFilePath = $_.FullName

    # Діагностика
    $TextFilePathName = [System.IO.Path]::GetFileName($TextFilePath)
    Write-Host "==============================" -ForegroundColor Yellow
    Write-Host "Clearing the file -> $TextFilePathName"

    # Шукаємо вміст файлу
    $content = Get-Content $TextFilePath

    # Очищаємо вміст від символів із blacklist
    $cleanedContent = $content | ForEach-Object {
        # Видаляємо всі символи з blacklist
        $_ -replace $blacklist, ''
    }

    # Зберігаємо очищений вміст назад у файл
    $cleanedContent | Set-Content -Path $TextFilePath

    # Діагностика
    Write-Host "The file has been cleaned and saved: $TextFilePath"
}



Write-Host "==============================" -ForegroundColor Yellow
Write-Host "Processing complete! Frames and text files are saved in the folder '$OutputDir'." -ForegroundColor Green
