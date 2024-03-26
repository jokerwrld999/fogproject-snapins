$autoLogonCount = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon"
$wallpaperRegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'
$wallpaperSourcePath = "C:\Windows\Setup\Scripts\wallpapers\warnWall.png"

function Lock-Workstation {
  powercfg -change -monitor-timeout-ac 0
  if ( $lockWorkstation::LockWorkStation() -eq 0 ) {
    throw 'Failed to lock workstation'
  }
}

function New-Registry {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [Parameter(Mandatory = $true)]
    [hashtable]$Properties
  )

  foreach ($property in $Properties.GetEnumerator()) {
    if (!(Test-Path $Path)) {
      New-Item -Path $Path -Force
    }

    if ((Get-ItemProperty -Path $Path -EA SilentlyContinue).PSObject.Properties[$property.Key].value -ne $property.Value) {
      New-ItemProperty -Path $Path -Name $property.Key -Value $property.Value -Force
    }
  }
}

function Disable-UserInput {
  $blockInput::BlockInput($true)
}

function Set-LockScreenWallpaper {
  param (
    [switch] $Clean
  )
  $blockInput = Add-Type -Name "UserInput" -PassThru -MemberDefinition @"
    [DllImport("user32.dll")]
    public static extern bool BlockInput(bool fBlockIt);
"@

  $lockWorkstation = Add-Type -Name "Win32LockWorkStation" -PassThru -MemberDefinition @"
    [DllImport("user32.dll")]
    public static extern int LockWorkStation();
"@

  Disable-UserInput | Out-Null

  $wallpaperItems = @(
    @{
      Path = $wallpaperRegistryPath
      Properties = @{
        LockScreenImagePath = $wallpaperSourcePath
      }
    }
  )

  foreach ($item in $wallpaperItems) {
    Write-Host "Adding Registry"
    New-Registry @item
    takeown /f "C:\ProgramData\Microsoft\Windows\SystemData" /r /d y
    icacls "C:\ProgramData\Microsoft\Windows\SystemData" /reset /t /c /l
  }

  Lock-Workstation | Out-Null

  if ($Clean) {
    Start-Sleep 10
    if (Test-Path $wallpaperRegistryPath) {
      Remove-Item -Path $wallpaperRegistryPath -Force | Out-Null
      takeown /f "C:\ProgramData\Microsoft\Windows\SystemData" /r /d y
      icacls "C:\ProgramData\Microsoft\Windows\SystemData" /reset /t /c /l
    }
  }

  Start-Sleep 50000
}

if ($autoLogonCount -gt 0) {
  reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v RunFirstLogonScript /d "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -File C:\Windows\Setup\Scripts\set_lockscreen_wallpaper.ps1 -Clean"
  Set-LockScreenWallpaper -Clean
}