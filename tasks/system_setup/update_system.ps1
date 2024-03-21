[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string] $domainMember
)

$winUpdateModule = "PSWindowsUpdate"
$getUser = Get-LocalGroupMember -Name "Administrators" -Member $domainMember
$languageTag = 'uk-UA'
$languageList = Get-WinUserLanguageList

if (!(Get-PackageProvider | Select-Object Name | Select-String "NuGet")) {
  Write-Host "Installing NuGet Provider..." -ForegroundColor Blue
  Install-PackageProvider -Name NuGet -Confirm:$False -Force
}

if (!(Get-Module -ListAvailable -Name $winUpdateModule)) {
  Install-Module -Name $winUpdateModule -Confirm:$False -Force | Out-Null
  Write-Host ("Installed module: $winUpdateModule") -ForegroundColor Green
}

Get-WindowsUpdate -Install -AcceptAll -IgnoreReboot -NotKBArticleID "KB5034441"

if (![bool]$getUser) {
  Write-Host "Adding User..."
  Add-LocalGroupMember -Name "Administrators" -Member $domainMember -ErrorAction SilentlyContinue
}

if (![bool]($languageList | Where-Object LanguageTag -like $languageTag)) {
  Write-Host "Installing $languageTag input language"
  $LanguageList.Add($languageTag)
  Set-WinUserLanguageList $languageList -Force
}