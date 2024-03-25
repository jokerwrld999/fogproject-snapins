sc config FOGService start= auto
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v RunFirstLogonScript /d "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoProfile -File C:\Windows\Setup\Scripts\first_login_wall.ps1"
shutdown -t 10 -r