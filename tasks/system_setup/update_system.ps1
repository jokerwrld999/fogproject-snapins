$moduleName = "PSWindowsUpdate"
if (!(Get-Module -ListAvailable -Name $moduleName)) {
  Install-Module -Name $moduleName -Confirm:$False -Force | Out-Null
  Write-Host ("Installed module: $moduleName") -ForegroundColor Green
}

Get-WindowsUpdate -Install -AcceptAll | Where-Object {$_.KB -notmatch "KB5034441"}


$languageTag = 'uk-UA'
$languageList = $(Get-WinUserLanguageList)
if (![bool]($languageList | Where-Object LanguageTag -like $languageTag)) {
  Write-Host "Installing $languageTag input language"
  Set-WinUserLanguageList -Confirm:$False $languageList
}