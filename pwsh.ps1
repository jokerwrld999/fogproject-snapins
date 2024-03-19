
$wallpaperRegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'
$wallpaperSourcePath = "C:\Windows\Setup\Scripts\wallpapers\warnWall.png"


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