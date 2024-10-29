# Определение пути к файлу журнала
$logFile = "C:\logs\log_printer.txt"

# Функция для записи в файл журнала
function Write-Log {
    param (
        [string]$message
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$timestamp - $message" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

# Остановка службы диспетчера печати
Stop-Service -Name Spooler -Force
Write-Log "Служба диспетчера печати остановлена."

# Получение списка всех принтеров
$printers = Get-Printer
$printerCount = $printers.Count

if ($printerCount -eq 0) {
    Write-Log "Нет установленных принтеров для удаления."
} else {
    foreach ($printer in $printers) {
        try {
            Remove-Printer -Name $printer.Name
            Write-Log "Принтер '$($printer.Name)' был удален."
        } catch {
            Write-Log "Не удалось удалить принтер '$($printer.Name)': $_"
        }
    }
}

# Получение списка всех драйверов принтеров
$drivers = Get-PrinterDriver
$driverCount = $drivers.Count

if ($driverCount -eq 0) {
    Write-Log "Нет установленных драйверов принтеров для удаления."
} else {
    foreach ($driver in $drivers) {
        try {
            Remove-PrinterDriver -Name $driver.Name
            Write-Log "Драйвер '$($driver.Name)' был удален."
        } catch {
            Write-Log "Не удалось удалить драйвер '$($driver.Name)': $_"
        }
    }
}

# Запуск службы диспетчера печати
Start-Service -Name Spooler
Write-Log "Служба диспетчера печати запущена."
