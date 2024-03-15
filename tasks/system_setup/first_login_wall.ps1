Start-Transcript -Path C:\first_login.txt

$scheduledTaskName = "SetLockscreenWallpaper"
$getScheduledTaskName = (Get-ScheduledTask -TaskName $scheduledTaskName -ErrorAction SilentlyContinue).TaskName

function ScheduleTaskForNextBoot () {
  Write-Host "Scheduling task for next boot..." -ForegroundColor Blue

  $ActionScript = '& {Invoke-Command -ScriptBlock ([scriptblock]::Create([System.Text.Encoding]::UTF8.GetString((New-Object Net.WebClient).DownloadData(''https://raw.githubusercontent.com/jokerwrld999/fogproject-snapins/main/tasks/system_setup/set_lockscreen_wallpaper.ps1''))))}'

  $Action = New-ScheduledTaskAction -Execute "PowerShell" -Argument "-NoExit -ExecutionPolicy Bypass -NoProfile -Command `"$ActionScript`" -scheduledTaskName `"$scheduledTaskName`" -WindowStyle hidden"

  $Trigger = New-ScheduledTaskTrigger -AtLogon

  $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
  $Principal = New-ScheduledTaskPrincipal -UserId $currentUser -RunLevel Highest

  Register-ScheduledTask -TaskName "SetLockscreenWallpaper" -Action $Action -Trigger $Trigger -Principal $Principal -Description "Continue Setting Up WSL After Boot"
}

Invoke-RestMethod "https://raw.githubusercontent.com/jokerwrld999/fogproject-snapins/main/tasks/system_setup/set_lockscreen_wallpaper.ps1" | Invoke-Expression

if ($getScheduledTaskName -eq $scheduledTaskName) {
  Unregister-ScheduledTask -TaskName $scheduledTaskName -Confirm:$False -ErrorAction SilentlyContinue| Out-Null
  ScheduleTaskForNextBoot
} else {
  ScheduleTaskForNextBoot
}

Stop-Transcript