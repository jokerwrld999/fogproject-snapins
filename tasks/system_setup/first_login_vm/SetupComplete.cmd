sc config FOGService start= auto
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v RunFirstLogonScript /d "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -File C:\Windows\Setup\Scripts\set_lockscreen_wallpaper.ps1"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v InstallVirtIODrivers /d "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -File C:\Windows\Setup\Scripts\virtio_drivers.ps1"
shutdown -t 15 -r