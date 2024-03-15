Start-Transcript -Path C:\first_login.txt

$scheduledTaskName = "SetLockscreenWallpaper"
$getScheduledTaskName = (Get-ScheduledTask -TaskName $scheduledTaskName -ErrorAction SilentlyContinue).TaskName

function ScheduleTaskForNextBoot () {
  Write-Host "Scheduling task $scheduledTaskName for next boot..." -ForegroundColor Blue

  $ActionScript = "& ([ScriptBlock]::Create((irm https://raw.githubusercontent.com/jokerwrld999/fogproject-snapins/main/tasks/system_setup/set_lockscreen_wallpaper.ps1))) -scheduledTaskName $scheduledTaskName"

  $Action = New-ScheduledTaskAction -Execute "PowerShell" -Argument "-NoExit -ExecutionPolicy Bypass -NoProfile -Command `"$ActionScript`""

  $Trigger = New-ScheduledTaskTrigger -AtLogon

  $currentUser = "$(hostname)\User"
  $Principal = New-ScheduledTaskPrincipal -UserId $currentUser -RunLevel Highest

  Register-ScheduledTask -TaskName "SetLockscreenWallpaper" -Action $Action -Trigger $Trigger -Principal $Principal -Description "Set Lockscreen Warning"
}

 powershell -ExecutionPolicy Bypass -NoProfile -Command "Invoke-RestMethod 'https://github.com/jokerwrld999/fogproject-snapins/raw/main/tasks/system_setup/set_lockscreen_wallpaper.ps1' | Invoke-Expression"

if ($getScheduledTaskName -eq $scheduledTaskName) {
  Unregister-ScheduledTask -TaskName $scheduledTaskName -Confirm:$False -ErrorAction SilentlyContinue| Out-Null
  ScheduleTaskForNextBoot
} else {
  ScheduleTaskForNextBoot
}

Stop-Transcript