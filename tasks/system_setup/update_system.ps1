[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string] $domainMember
)

$winUpdateModule = "PSWindowsUpdate"
$languageTag = 'uk-UA'

if (!(Get-PackageProvider | Select-Object Name | Select-String "NuGet")) {
  Write-Host "Installing NuGet Provider..." -ForegroundColor Blue
  Install-PackageProvider -Name NuGet -Confirm:$False -Force
}

if (!(Get-Module -ListAvailable -Name $winUpdateModule)) {
  Install-Module -Name $winUpdateModule -Confirm:$False -Force | Out-Null
  Write-Host ("Installed module: $winUpdateModule") -ForegroundColor Green
}

Install-WindowsUpdate -NotCategory "Drivers" -AcceptAll -IgnoreReboot

if ((Get-WindowsCapability -Online -Name NetFx3~~~~).State -ne "Installed") {
  Write-Host "Installing .NET Framework 3.5..." -ForegroundColor Blue
  Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3"
}

if (-not (Get-LocalGroupMember -Name "Administrators" -Member $domainMember -ErrorAction SilentlyContinue)) {
    Write-Host "Adding User..." -ForegroundColor Blue
    Add-LocalGroupMember -Name "Administrators" -Member $domainMember -ErrorAction SilentlyContinue
}

if (!((Get-WinUserLanguageList).LanguageTag -contains 'uk')) {
  Write-Host "Installing $languageTag input language..." -ForegroundColor Blue
  $languageList = Get-WinUserLanguageList
  $languageList.Add($languageTag)
  Set-WinUserLanguageList $languageList -Force
}