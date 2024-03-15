[CmdletBinding()]
param(
  [Parameter(Mandatory = $false)]
  [string] $scheduledTaskName
)

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

$wallpaperTempPath = "C:\WarnTemp"
$wallpaperRemotePath = "https://github.com/jokerwrld999/fogproject-snapins/raw/main/files/wallpapers/warnWall.png"
$wallpaperSourcePath = "$wallpaperTempPath\warnWall.png"
$wallpaperRegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'
# $scheduledTaskName = "SetLockscreenWallpaper"
$getScheduledTaskName = (Get-ScheduledTask -TaskName $scheduledTaskName -ErrorAction SilentlyContinue).TaskName

$lockWorkstation = Add-Type -Name "Win32LockWorkStation" -PassThru -MemberDefinition @"
  [DllImport("user32.dll")]
  public static extern int LockWorkStation();
"@

function Lock-Workstation {
  if ( $lockWorkstation::LockWorkStation() -eq 0 ) {
      throw 'Failed to lock workstation'
  }
}

$blockInput = Add-Type -Name "UserInput" -PassThru -MemberDefinition @"
  [DllImport("user32.dll")]
  public static extern bool BlockInput(bool fBlockIt);
"@

function Disable-UserInput {
  $blockInput::BlockInput($true)
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
      New-Item -Path $Path -Force | Out-Null
    }

    if ((Get-ItemProperty -Path $Path -EA SilentlyContinue).PSObject.Properties[$property.Key].value -ne $property.Value) {
      New-ItemProperty -Path $Path -Name $property.Key -Value $property.Value -Force | Out-Null
    }
  }
}

if (!(Test-Path -Path $wallpaperSourcePath)) {
  if (!(Test-Path -Path $wallpaperTempPath)) {
    New-Item -Path $wallpaperTempPath -ItemType Directory | Out-Null
  }
  Invoke-WebRequest -Uri $wallpaperRemotePath -OutFile $wallpaperSourcePath
}

$wallpaperItems = @(
  @{
    Path = $wallpaperRegistryPath
    Properties = @{
      LockScreenImagePath = $wallpaperSourcePath
    }
  }
)

foreach ($item in $wallpaperItems) {
  New-Registry @item
}

Disable-UserInput | Out-Null
Lock-Workstation | Out-Null

if (Test-Path $wallpaperRegistryPath) {
  Start-Sleep 10
  Remove-Item -Path $wallpaperRegistryPath -Force | Out-Null
  if (Test-Path -Path $wallpaperTempPath) {
    Remove-Item -Path $wallpaperTempPath -Recurse -Force | Out-Null
  }
}

if ($getScheduledTaskName -eq $scheduledTaskName) {
  Unregister-ScheduledTask -TaskName $scheduledTaskName -Confirm:$False -ErrorAction SilentlyContinue | Out-Null
}