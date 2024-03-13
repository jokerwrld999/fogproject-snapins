[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string] $networkUser,
  [Parameter(Mandatory = $true)]
  [string] $networkPass,
  [Parameter(Mandatory = $true)]
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

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "$snapinScriptPath\tasks\drivers\hp_z640_drivers.ps1" -networkSharePath $networkSharePath -gitRepoPath $gitRepoPath
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "$snapinScriptPath\tasks\drivers\nvidia.ps1"
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "$snapinScriptPath\tasks\software\scoop_packages.ps1"
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "$snapinScriptPath\\files\helper_scripts\add_domain_user.ps1" -domainMember $domainMember
& ([ScriptBlock]::Create((irm https://massgrave.dev/get))) /HWID
& ([ScriptBlock]::Create((irm "https://raw.githubusercontent.com/jokerwrld999/fogproject-snapins/main/files/helper_scripts/send_telegram_message.ps1"))) -botToken $botToken -chatID $chatID

net use $networkSharePath /delete