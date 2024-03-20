[CmdletBinding()]
param(
  [Parameter(Mandatory = $false)]
  [string] $scheduledTaskName
)
Start-Transcript -Path C:\lockscreen_log.txt

$wallpaperRegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'
$wallpaperSourcePath = "C:\Windows\Setup\Scripts\wallpapers\warnWall.png"
$getScheduledTaskName = (Get-ScheduledTask -TaskName $scheduledTaskName -ErrorAction SilentlyContinue).TaskName

$blockInput = Add-Type -Name "UserInput" -PassThru -MemberDefinition @"
[DllImport("user32.dll")]
public static extern bool BlockInput(bool fBlockIt);
"@

$lockWorkstation = Add-Type -Name "Win32LockWorkStation" -PassThru -MemberDefinition @"
  [DllImport("user32.dll")]
  public static extern int LockWorkStation();
"@

function Disable-UserInput {
  $blockInput::BlockInput($true)
}

Disable-UserInput | Out-Null

function Lock-Workstation {
  # Start-Sleep 5
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

$wallpaperItems = @(
  @{
    Path = $wallpaperRegistryPath
    Properties = @{
      LockScreenImagePath = $wallpaperSourcePath
      # LockScreenImageUrl = $wallpaperSourcePath
      # LockScreenImageStatus = 1
    }
  }
)

foreach ($item in $wallpaperItems) {
  Write-Host "Adding Registry"
  New-Registry @item
  takeown /f "C:\ProgramData\Microsoft\Windows\SystemData" /r /d y
  icacls "C:\ProgramData\Microsoft\Windows\SystemData" /reset /t /c /l
}

if ($scheduledTaskName -eq $getScheduledTaskName) {
  Write-Host "Unregistering Task......"
  Unregister-ScheduledTask -TaskName $scheduledTaskName -Confirm:$False -ErrorAction SilentlyContinue | Out-Null
  if (Test-Path $wallpaperRegistryPath) {
    Remove-Item -Path $wallpaperRegistryPath -Force | Out-Null
  }
  powercfg -change -monitor-timeout-ac 1
}

Lock-Workstation | Out-Null

Stop-Transcript

Start-Sleep 50000