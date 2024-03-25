$msiPath = "D:\virtio-win-gt-x64.msi"
$logsPath = "C:\Windows\Setup\Logs"
if (!(Test-Path -Path $logsPath)) {
  New-Item -Type Directory -Path $logsPath -Force | Out-Null
}
Start-Process msiexec.exe "/i $msiPath /quiet /qn /passive /norestart" -Wait | Out-File "logsPath\virtio.txt"