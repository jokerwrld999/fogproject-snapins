[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string] $networkSharePath,
  [Parameter(Mandatory = $true)]
  [string] $gitRepoPath
)

$driverTempPath = "C:\DesktopTemp"
$7zipRemote = "https://www.7-zip.org/a/7z2301-x64.exe"
$7zipSrc = "$driverTempPath\7zip.exe"
$7zipExe = "$env:programfiles\7-Zip\7z.exe"
$drivers = @(
  @{ Name = "Intel Chipset";
    driverID = "$(pnputil /enum-devices /problem | Select-String 'VEN_8086')";
    driverRemote = "$networkSharePath\$gitRepoPath\files\desktop_drivers\Chipset.zip";
    sourceUnzipPath = "$driverTempPath\Chipset.zip";
    destinationUnzipPath = $driverTempPath;
    driverExe = "Chipset\SetupChipset.exe";
    installSwitches = "-s -norestart"
  },
  @{ Name = "Intel Serial IO";
    driverID = "$(pnputil /enum-devices /problem | Select-String 'VEN_8086&DEV_43E9')";
    driverRemote = "$networkSharePath\$gitRepoPath\files\desktop_drivers\IOserial.zip";
    sourceUnzipPath = "$driverTempPath\IOserial.zip";
    destinationUnzipPath = $driverTempPath;
    driverExe = "Chipset\AsusSetup.exe";
    installSwitches = "-s -norestart"
  }
)

if (!(Test-Path -Path $driverTempPath)) {
  New-Item -Type Directory -Path $driverTempPath | Out-Null
}

if (!(Test-Path -Path $7zipExe) -and ![bool](Get-Command 7z -ErrorAction SilentlyContinue)) {
  Write-Host "####### Installing 7zip... #######" -ForegroundColor Blue
  (New-Object System.Net.WebClient).DownloadFile($7zipRemote,$7zipSrc)
  Start-Process -FilePath $7zipSrc -ArgumentList "/S" -Wait
}

foreach ($driver in $drivers) {
  if ([bool]$driver.driverID) {
    if (!(Test-Path -Path "$($driver.destinationUnzipPath)\$($driver.driverExe)")) {
      Write-Host "####### Downloading Desktop $($driver.Name) Driver... #######" -ForegroundColor Blue
      (New-Object System.Net.WebClient).DownloadFile($driver.driverRemote,$driver.sourceUnzipPath)
    }

    if (!(Test-Path -Path "$($driver.destinationUnzipPath)\$($driver.driverExe)")) {
      Write-Host "####### Extracting Desktop $($driver.Name) Driver... #######" -ForegroundColor Blue
      if (Test-Path -Path $7zipExe){
        Start-Process $7zipExe -ArgumentList "x $($driver.sourceUnzipPath) `"-o$($driver.destinationUnzipPath)`" -y -bso0 -bd" -NoNewWindow -Wait
      } else {
        Start-Process 7z -ArgumentList "x $($driver.sourceUnzipPath) `"-o$($driver.destinationUnzipPath)`" -y -bso0 -bd" -NoNewWindow -Wait
      }
    }
    Write-Host "####### Installing Desktop $($driver.Name) Driver... #######" -ForegroundColor Blue
    Start-Process -FilePath "$($driver.destinationUnzipPath)\$($driver.driverExe)" -ArgumentList $driver.installSwitches -Wait
  } else {
      Write-Host "####### Desktop $($driver.Name) Driver has been already installed. #######" -ForegroundColor Green
  }
}

if (Test-Path -Path $driverTempPath) {
  Remove-Item -Path $driverTempPath -Recurse -Force | Out-Null
}
