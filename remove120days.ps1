# Remove Mobile devices not synced for 120 days

#connect to Exchange Online
Connect-ExchangeOnline

$devices = Get-MobileDevice -resultsize unlimited
foreach ($device in $devices) {
	$ds = Get-MobileDeviceStatistics -identity $device.id
	If ($ds.LastSuccessSync -lt (Get-Date).AddDays(-120)) {
		Write-host $device.UserDisplayName $device.deviceos $ds.LastSuccessSync " removing..." -foreground red
		Remove-MobileDevice $device.id -confirm:$false
	}
	else {
		Write-host $device.UserDisplayName $device.deviceos $ds.LastSuccessSync " good" -foreground green
	}
}

$oldDevices = Get-MobileDevice -resultsize unlimited |
    Get-MobileDeviceStatistics |
    Where-Object {$_.LastSuccessSync -le (Get-Date).AddDays("-90")}

$oldDevices | foreach-object {
    if ($Warn)
    {
        $null = $Warn.Message -match "Actual delayed:\s(?'Delay'[0-9]+)\s"
        Start-Sleep -Milliseconds $Matches.Delay
        $Warn = $null
    }
    Remove-MobileDevice ([string]$_.Guid.Guid) -confirm:$false -WarningVariable Warn
}