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

$networkSharePath = "\\10.2.252.13\All\Department\Sysadmins\Fog"
$gitRepoPath = "github\fogproject-snapins"
$snapinScriptPath = "$networkSharePath\$gitRepoPath"

net use $networkSharePath /user:$networkUser $networkPass

$chipsetLog = $(powershell.exe -ExecutionPolicy Bypass -NoProfile -File "$snapinScriptPath\tasks\drivers\desktop_chipset_drivers.ps1" -networkSharePath $networkSharePath -gitRepoPath $gitRepoPath)
$nvidiaLog = $(powershell.exe -ExecutionPolicy Bypass -NoProfile -File "$snapinScriptPath\tasks\drivers\nvidia.ps1")
$scoopLog = $(powershell.exe -ExecutionPolicy Bypass -NoProfile -File "$snapinScriptPath\tasks\software\scoop_packages.ps1")
$domainMemberLog = $(powershell.exe -ExecutionPolicy Bypass -NoProfile -File "$snapinScriptPath\tasks\system_setup\add_domain_user.ps1" -domainMember $domainMember)
& ([ScriptBlock]::Create((irm https://massgrave.dev/get))) /HWID

$logMessage = "$chipsetLog \n " + "$nvidiaLog \n" + "$scoopLog \n" + "$domainMemberLog"

& ([ScriptBlock]::Create((irm "https://raw.githubusercontent.com/jokerwrld999/fogproject-snapins/main/tasks/system_setup/send_telegram_message.ps1"))) -botToken $botToken -chatID $chatID -logMessage $logMessage

net use $networkSharePath /delete