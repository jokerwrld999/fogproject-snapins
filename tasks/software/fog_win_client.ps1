$fogTempPath = "C:\FogTemp"
$fogMsiPath = "$fogTempPath\fog.msi"
$fogInstalledPath = "C:\Program Files (x86)\FOG\FOGService.exe"
$fogServerIP = "10.2.252.200"
$fogServiceName = "*Fog*"


if (!(Test-Path $fogInstalledPath)) {
  if (!(Test-Path $fogMsiPath)) {
    New-Item -Type Directory -Path $fogTempPath | Out-Null
  }
  (New-Object System.Net.WebClient).DownloadFile("http://$fogServerIP/fog/client/download.php?newclient",$fogMsiPath)
  Start-Process msiexec.exe "/i $fogMsiPath /quiet /norestart /qn USETRAY=`"0`" WEBADDRESS=`"$fogServerIP`" ROOTLOG=`"0`"" -Wait
}

if ((get-Service "*Fog*").Status -ne "Running") {
  Get-Service $fogServiceName | Set-Service -Status Running -StartupType Automatic
}

if (Test-Path $fogTempPath) {
  Remove-Item -Path $fogTempPath -Recurse -ErrorAction SilentlyContinue -Force
}
