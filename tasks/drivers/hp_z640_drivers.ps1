[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string] $networkSharePath,
  [Parameter(Mandatory = $true)]
  [string] $gitRepoPath
)

$driverTempPath = "C:\HpTemp"
$intelRSTExe = "C:\Program Files (x86)\Intel\Intel(R) Rapid Storage Technology enterprise\IAStorUI.exe"
$7zipRemote = "https://www.7-zip.org/a/7z2301-x64.exe"
$7zipSrc = "$driverTempPath\7zip.exe"
$7zipExe = "$env:programfiles\7-Zip\7z.exe"

function Test-ProblemDriver {
  param (
      [string]$hardwareID
  )
  $deviceStatus = pnputil /enum-devices /problem | Select-String $hardwareID
  return -not $deviceStatus
}


if (!(Test-Path -Path $driverTempPath)) {
  New-Item -Type Directory -Path $driverTempPath | Out-Null
}

if (!(Test-Path -Path $7zipExe) -and ![bool](Get-Command 7z -ErrorAction SilentlyContinue)) {
  Write-Host "####### Installing 7zip... #######" -ForegroundColor Blue
  (New-Object System.Net.WebClient).DownloadFile($7zipRemote,$7zipSrc)
  Start-Process -FilePath $7zipSrc -ArgumentList "/S" -Wait
}

$drivers = @(
  @{ Name = "Intel Rapid Storage Technology";
    driverRemote = "$networkSharePath\$gitRepoPath\files\hp_z640_drivers\IntelRST(sp96420).exe";
    sourceUnzipPath = "$driverTempPath\rst.exe";
    destinationUnzipPath = "$driverTempPath\RST";
    driverExe = "Setup.exe";
    installSwitches = "-notray -s"
  },
  @{ Name = "Intel Management Engine";
    hardwareID = 'VEN_8086&DEV_8D3D&SUBSYS_212A103C';
    driverRemote = "$networkSharePath\$gitRepoPath\files\hp_z640_drivers\IntelME(sp74499).exe";
    sourceUnzipPath = "$driverTempPath\intelME.exe";
    destinationUnzipPath = "$driverTempPath\IntelME";
    driverExe = "SetupME.exe";
    installSwitches = "-overwrite -noIMSS -s"
  },
  @{ Name = "Intel Chipset";
    hardwareID = 'VEN_8086';
    driverRemote = "$networkSharePath\$gitRepoPath\files\hp_z640_drivers\Chipset(sp101759).exe";
    sourceUnzipPath = "$driverTempPath\Chipset.exe";
    destinationUnzipPath = "$driverTempPath\Chipset";
    driverExe = "SetupChipset.exe";
    installSwitches = "-s -norestart"
  }
)

foreach ($driver in $drivers) {
  if ( (Test-ProblemDriver -hardwareID $driver.hardwareID) -or ($driver.Name -eq "Intel Rapid Storage Technology" -and !(Test-Path -Path $intelRSTExe)) ) {
    if (!(Test-Path -Path "$($driver.destinationUnzipPath)\$($driver.driverExe)")) {
      Write-Host "####### Downloading HP $($driver.Name) Driver... #######" -ForegroundColor Blue
      (New-Object System.Net.WebClient).DownloadFile($driver.driverRemote,$driver.sourceUnzipPath)
    }

    if (!(Test-Path -Path "$($driver.destinationUnzipPath)\$($driver.driverExe)")) {
      Write-Host "####### Extracting HP $($driver.Name) Driver... #######" -ForegroundColor Blue
      if (Test-Path -Path $7zipExe){
        Start-Process $7zipExe -ArgumentList "x $($driver.sourceUnzipPath) `"-o$($driver.destinationUnzipPath)`" -y -bso0 -bd" -NoNewWindow -Wait
      } else {
        Start-Process 7z -ArgumentList "x $($driver.sourceUnzipPath) `"-o$($driver.destinationUnzipPath)`" -y -bso0 -bd" -NoNewWindow -Wait
      }
    }
    Write-Host "####### Installing HP $($driver.Name) Driver... #######" -ForegroundColor Blue
    Start-Process -FilePath "$($driver.destinationUnzipPath)\$($driver.driverExe)" -ArgumentList $driver.installSwitches -Wait
  } else {
      Write-Host "####### HP $($driver.Name) Driver has been already installed. #######" -ForegroundColor Green
  }
}

if (Test-Path -Path $driverTempPath) {
  Remove-Item -Path $driverTempPath -Recurse -Force | Out-Null
}
