[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string] $networkSharePath,
  [Parameter(Mandatory = $true)]
  [string] $gitRepoPath
)

$jobName = "InstallNinite"
$niniteTempPath= "C:\NiniteTemp"
$niniteAppsSource = "$niniteTempPath\NiniteApps.exe"
$niniteAppsRemote = "$networkSharePath\$gitRepoPath\files\ninite\NiniteApps.exe"
$niniteAppsInstalled = "C:\Program Files\Google\Chrome\Application\chrome.exe"

if (!(Test-Path -Path $niniteAppsInstalled)) {
  if (!(Test-Path -Path $niniteTempPath)) {
    Write-Host "####### Downloading Ninite Apps... #######" -ForegroundColor Blue
    New-Item -Path $niniteTempPath -ItemType Directory | Out-Null
    Invoke-WebRequest -Uri $niniteAppsRemote -OutFile $niniteAppsSource
  }

  Write-Host "####### Installing Ninite Apps... #######" -ForegroundColor Blue
  Start-Job -Name $jobName -ScriptBlock {
    Start-Process -WindowStyle hidden -FilePath "C:\NiniteTemp\NiniteApps.exe" -Wait
  } | Out-Null

  while ($true) {
    if ((Test-Path -Path $niniteAppsInstalled)) {
      taskkill.exe /IM "Ninite.exe" /F
      taskkill.exe /IM "NiniteApps.exe" /F
      Stop-Job -Name $jobName
      Remove-Job -Name $jobName
      Write-Host "####### Ninite Apps installed successfully. #######" -ForegroundColor Green
      break
    }
    Start-Sleep 30
  }

  if ((Test-Path -Path $niniteTempPath)) {
    Write-Host "####### Cleaning $niniteTempPath... #######" -ForegroundColor Blue
    Remove-Item -Path $niniteTempPath -Recurse -Force | Out-Null
  }
} else {
  Write-Host "####### Ninite Apps has been already installed. #######" -ForegroundColor Green
}
