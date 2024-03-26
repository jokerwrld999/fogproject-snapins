$msiPath = "D:\virtio-win-gt-x64.msi"

Start-Process msiexec.exe "/i $msiPath /quiet /qn /passive /norestart" -Wait