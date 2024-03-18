function Disable-UserInput($seconds) {
  Get-PnpDevice -FriendlyName "*Mouse*" | ForEach-Object { Disable-PnpDevice -InputObject $_ -Confirm:$false -ErrorAction SilentlyContinue }
  Get-PnpDevice -FriendlyName "*Keyboard*" | ForEach-Object { Disable-PnpDevice -InputObject $_ -Confirm:$false -ErrorAction SilentlyContinue }

  Write-Host "Wait please..." -ForegroundColor Blue
  Start-Sleep $seconds

  Get-PnpDevice -FriendlyName "*Mouse*" | ForEach-Object { Enable-PnpDevice -InputObject $_ -Confirm:$false -ErrorAction SilentlyContinue }
  Get-PnpDevice -FriendlyName "*Keyboard*" | ForEach-Object { Enable-PnpDevice -InputObject $_ -Confirm:$false -ErrorAction SilentlyContinue }
}

Disable-UserInput -seconds 120 | Out-Null