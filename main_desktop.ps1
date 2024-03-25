[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string] $networkUser,
  [Parameter(Mandatory = $true)]
  [string] $networkPass,
  [Parameter(Mandatory = $false)]
  [string] $domainMember,
  [Parameter(Mandatory = $false)]
  [string] $botToken,
  [Parameter(Mandatory = $false)]
  [string] $chatID
)

Start-Sleep 30

$networkSharePath = "\\10.2.252.13\All\Department\Sysadmins\Fog"
$gitRepoPath = "github\fogproject-snapins"
$snapinScriptPath = "$networkSharePath\$gitRepoPath"
$logsPath = "C:\Windows\Setup\Logs"

if (!(Test-Path -Path $logsPath)) {
  New-Item -Type Directory -Path $logsPath -Force | Out-Null
}

Start-Transcript -Path "$logsPath\0_main_snapin.txt"

net use $networkSharePath /user:$networkUser $networkPass

Start-Sleep 30

powercfg -change -monitor-timeout-ac 0

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "$snapinScriptPath\tasks\drivers\desktop_chipset_drivers.ps1" -networkSharePath $networkSharePath -gitRepoPath $gitRepoPath | Out-File "$logsPath\1_chipset.txt"
Start-Sleep 30

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "$snapinScriptPath\tasks\drivers\nvidia.ps1" | Out-File "$logsPath\2_nvidia.txt"
Start-Sleep 30

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "$snapinScriptPath\tasks\software\scoop_packages.ps1" | Out-File "$logsPath\3_scoop.txt"
Start-Sleep 30

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "$snapinScriptPath\tasks\system_setup\update_system.ps1" -domainMember $domainMember | Out-File "$logsPath\4_update.txt"
Start-Sleep 30

& ([ScriptBlock]::Create((Invoke-RestMethod "https://massgrave.dev/get"))) /HWID

& ([ScriptBlock]::Create((Invoke-RestMethod "https://raw.githubusercontent.com/jokerwrld999/fogproject-snapins/main/tasks/system_setup/send_telegram_message.ps1"))) -botToken $botToken -chatID $chatID

powercfg -change -monitor-timeout-ac 15

net use $networkSharePath /delete

Stop-Transcript