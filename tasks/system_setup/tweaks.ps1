#Requires -RunAsAdministrator

$Global:registryChangesCount = 0
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
      $Global:registryChangesCount = $Global:registryChangesCount + 1
    }
  }
}

$RegistryTweaks = @(
  @{
    Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Properties = @{
      TaskbarGlomLevel = 0
      MMTaskbarEnabled = 1
      MMTaskbarMode = 2
      TaskbarMn = 0
      TaskbarDa = 0
      Start_SearchFiles = 1
    }
  },
  @{
    Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    Properties = @{
      AppsUseLightTheme = 0
      SystemUsesLightTheme = 0
    }
  },
  @{
    Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'
    Properties = @{
      SearchboxTaskbarMode = 1
    }
  },
  @{
    Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
    Properties = @{
      ContentDeliveryAllowed = 1
      RotatingLockScreenEnabled = 1
      RotatingLockScreenOverlayEnabled = 0
      "SubscribedContent-338388Enabled" = 0
      "SubscribedContent-338389Enabled" = 0
      "SubscribedContent-88000326Enabled" = 0
    }
  },
  @{
    Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'
    Properties = @{
      AllowTelemetry = 0
    }
  },
  @{
    Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
    Properties = @{
      NoPinningStoreToTaskbar = 1
    }
  },
  @{
    Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'
    Properties = @{
      DesktopImagePath = "C:\Windows\Web\Wallpaper\Windows\pingle.png"
    }
  }
)

foreach ($tweak in $RegistryTweaks) {
  New-Registry @tweak
}

if ($Global:registryChangesCount -ne 0) {
  Write-Host ("Restarting Explorer...") -ForegroundColor Blue
  Get-Process -Name explorer -EA SilentlyContinue | Stop-Process
}