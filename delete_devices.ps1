# Получаем список всех устройств и сортируем его по имени
$devices = Get-PnpDevice | Sort-Object FriendlyName

# Создаем массивы для хранения InstanceId активных и неактивных устройств
$activeDevices = @()
$inactiveDevices = @()

# Проходим по каждому устройству, выводим информацию и определяем его статус
foreach ($device in $devices) {
    if ($device.Status -eq 'OK') {
        Write-Host "$($device.FriendlyName) (Активно)" -ForegroundColor Green
        $activeDevices += $device.InstanceId
    } else {
        Write-Host "$($device.FriendlyName) (Не активно)" -ForegroundColor Red
        $inactiveDevices += $device.InstanceId
    }
}

# Если найдены неактивные устройства
if ($inactiveDevices.Count -gt 0) {
    # Выводим информацию о количестве неактивных устройств и запрашиваем подтверждение на удаление
    Write-Host "Найдено неактивных устройств: $($inactiveDevices.Count)"
    $confirm = Read-Host "Хотите удалить все неактивные устройства? (y/n)"
    
    # Если пользователь согласен удалить неактивные устройства
    if ($confirm -eq 'y') {
        # Проходим по списку неактивных устройств и удаляем их
        foreach ($deviceId in $inactiveDevices) {
            $device = $devices | Where-Object { $_.InstanceId -eq $deviceId }
            $Result = & pnputil /remove-device $deviceId
            if ($LastExitCode -eq 0) {
                Write-Host "Устройство '$($device.FriendlyName)' с InstanceId $deviceId было удалено.`n" -ForegroundColor Yellow
            } else {
                Write-Host "Устройство '$($device.FriendlyName)' с InstanceId $deviceId не было удалено.`n" -ForegroundColor Magenta
            }
        }
    } else {
        # Если пользователь не согласен на удаление
        Write-Host "Неактивные устройства НЕ были удалены." -ForegroundColor Cyan
    }
} else {
    # Если неактивных устройств нет
    Write-Host "Не найдено неактивных устройств." -ForegroundColor Cyan
}

# Определяем путь для записи лога
$logFilePath = "C:\logs\delete_log.txt"

# Создаем строку с информацией о результате выполнения скрипта
$logMessage = "$(Get-Date) "

$removedDevicesLog = foreach ($deviceId in $inactiveDevices) {
    $device = $devices | Where-Object { $_.InstanceId -eq $deviceId }
    $removedDeviceInfo = "Устройство '$($device.FriendlyName)' с InstanceId $deviceId"
    
    if ($confirm -eq 'y') {
        $removedDeviceInfo += " было удалено.`n"
    } elseif ($confirm -eq 'n') {
        $removedDeviceInfo += " не было удалено.`n"
    }
    
    $removedDeviceInfo
}

if ($inactiveDevices.Count -eq 0) {
    $logMessage += "Не найдено неактивных устройств"
} else {
    $logMessage += "Неактивные устройства были удалены"
}

# Дополняем информацию в логе
Add-Content -Path $logFilePath -Value ($logMessage + "`n" + $removedDevicesLog)
