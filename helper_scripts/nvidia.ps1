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

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "$snapinScriptPath\drivers\nvidia.ps1"

net use $networkShare /delete