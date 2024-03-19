[CmdletBinding()]
param(
  [Parameter(Mandatory = $false)]
  [string] $scheduledTaskName
)

Start-Transcript -Path C:\lockscreen_log.txt

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

$wallpaperSourcePath = "C:\Windows\Setup\Scripts\wallpapers\warnWall.png"
$wallpaperRegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'
$getScheduledTaskName = (Get-ScheduledTask -TaskName $scheduledTaskName -ErrorAction SilentlyContinue).TaskName

$blockInput = Add-Type -Name "UserInput" -PassThru -MemberDefinition @"
[DllImport("user32.dll")]
public static extern bool BlockInput(bool fBlockIt);
"@

function Disable-UserInput {
  $blockInput::BlockInput($true)
}

Disable-UserInput | Out-Null

$lockWorkstation = Add-Type -Name "Win32LockWorkStation" -PassThru -MemberDefinition @"
  [DllImport("user32.dll")]
  public static extern int LockWorkStation();
"@

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

$wallpaperItems = @(
  @{
    Path = $wallpaperRegistryPath
    Properties = @{
      LockScreenImagePath = $wallpaperSourcePath
      LockScreenImageUrl = $wallpaperSourcePath
      LockScreenImageStatus = 1
    }
  }
)

foreach ($item in $wallpaperItems) {
  New-Registry @item
}

Lock-Workstation | Out-Null

if ($scheduledTaskName -eq $getScheduledTaskName) {
  Unregister-ScheduledTask -TaskName $scheduledTaskName -Confirm:$False -ErrorAction SilentlyContinue | Out-Null
  if (Test-Path $wallpaperRegistryPath) {
    Remove-Item -Path $wallpaperRegistryPath -Force | Out-Null
  }
  powercfg -change -monitor-timeout-ac 1
}

Stop-Transcript

Start-Sleep 50000