[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string] $networkUser,
  [Parameter(Mandatory = $true)]
  [string] $networkPass
)

$networkSharePath = "\\10.2.252.13\All\Department\Sysadmins\Fog"
$gitRepoPath = "github\fogproject-snapins"
$snapinScriptPath = "$networkSharePath\$gitRepoPath"

net use $networkSharePath /user:$networkUser $networkPass

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "$snapinScriptPath\tasks\software\scoop_packages.ps1"

net use $networkSharePath /delete