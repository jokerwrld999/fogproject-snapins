[CmdletBinding()]
param(
  [Parameter(Mandatory = $false)]
  [string] $scheduledTaskName
)

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
  Start-Sleep 10
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
      New-Item -Path $Path -Force | Out-Null
    }

    if ((Get-ItemProperty -Path $Path -EA SilentlyContinue).PSObject.Properties[$property.Key].value -ne $property.Value) {
      New-ItemProperty -Path $Path -Name $property.Key -Value $property.Value -Force | Out-Null
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
  RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters 1, True
}

Lock-Workstation | Out-Null

if ([bool]$scheduledTaskName -and ($getScheduledTaskName -eq $scheduledTaskName)) {
  Unregister-ScheduledTask -TaskName $scheduledTaskName -Confirm:$False -ErrorAction SilentlyContinue | Out-Null
  if (Test-Path $wallpaperRegistryPath) {
    Remove-Item -Path $wallpaperRegistryPath -Force | Out-Null
  }
}

Start-Sleep 50000