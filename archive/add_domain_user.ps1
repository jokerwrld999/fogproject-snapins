[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string] $domainMember
)

$getUser = Get-LocalGroupMember -Name "Administrators" -Member $domainMember

if (![bool]$getUser) {
  Write-Host "Adding User..."
  Add-LocalGroupMember -Name "Administrators" -Member $domainMember
}
