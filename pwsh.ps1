[CmdletBinding()]
param(
  [Parameter(Mandatory = $false)]
  [string] $botToken,
  [Parameter(Mandatory = $false)]
  [string] $chatID
)

$logMessage = $(powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "Write-Host 'hostname'")
$logMessage = $(powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "Write-Host 'BigBoss'")

& ([ScriptBlock]::Create((irm "https://raw.githubusercontent.com/jokerwrld999/fogproject-snapins/main/tasks/system_setup/send_telegram_message.ps1"))) -botToken $botToken -chatID $chatID -logMessage $logMessage


Write-Host "your log is : $logMessage"