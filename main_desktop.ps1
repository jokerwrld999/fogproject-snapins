[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string] $networkUser,
  [Parameter(Mandatory = $true)]
  [string] $networkPass
)

$networkSharePath = "\\10.2.252.13\All\Department\Sysadmins\Fog"
$gitRepoPath = "$networkSharePath\github\fogproject-snapins"
$snapinScriptPath = "$networkSharePath\$gitRepoPath"

net use $networkShare /user:$networkUser $networkPass

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "$snapinScriptPath\drivers\desktop_chipset_drivers.ps1" -networkSharePath $networkSharePath -gitRepoPath $gitRepoPath
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "$snapinScriptPath\drivers\nvidia.ps1"
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "$snapinScriptPath\software\scoop_packages.ps1"

net use $networkShare /delete