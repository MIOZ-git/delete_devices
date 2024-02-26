# Получить список всех устройств и отсортировать его по имени
$devices = Get-PnpDevice | Sort-Object FriendlyName

# Создать массивы для хранения InstanceId активных и неактивных устройств
$activeDevices = @()
$inactiveDevices = @()

# Пройти по каждому устройству и вывести информацию с соответствующим цветом
foreach ($device in $devices) {
    if ($device.Status -eq 'OK') {
        Write-Host "$($device.FriendlyName) (Активно)" -ForegroundColor Green
        $activeDevices += $device.InstanceId
    } else {
        Write-Host "$($device.FriendlyName) (Не активно)" -ForegroundColor Red
        $inactiveDevices += $device.InstanceId
    }
}

if ($inactiveDevices.Count -gt 0) {
    Write-Host "Найдено неактивных устройств: $($inactiveDevices.Count)"
    $confirm = Read-Host "Хотите удалить все неактивные устройства? (y/n)"
    if ($confirm -eq 'y') {
        foreach ($deviceId in $inactiveDevices) {
            $Result = & pnputil /remove-device $deviceId
            if ($LastExitCode -eq 0) {
                Write-Host "Устройство с InstanceId $deviceId было удалено." -ForegroundColor Yellow
            } else {
                Write-Host "Устройство с InstanceId $deviceId не было удалено." -ForegroundColor Magenta
            }
        }
    } else {
        Write-Host "Неактивные устройства не были удалены." -ForegroundColor Cyan
    }
} else {
    Write-Host "Не найдено неактивных устройств." -ForegroundColor Cyan
}

