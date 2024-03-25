$scheduledTaskName = "SetLockscreenWallpaper"
$getScheduledTaskName = (Get-ScheduledTask -TaskName $scheduledTaskName -ErrorAction SilentlyContinue).TaskName

function ScheduleTaskForNextBoot () {
  Write-Host "Scheduling task $scheduledTaskName for next boot..." -ForegroundColor Blue

  $ActionScript = "C:\Windows\Setup\Scripts\set_lockscreen_wallpaper.ps1"

  $Action = New-ScheduledTaskAction -Execute "PowerShell" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -File $ActionScript -scheduledTaskName `"$scheduledTaskName`""

  $Trigger = New-ScheduledTaskTrigger -AtLogon

  $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
  $Principal = New-ScheduledTaskPrincipal -UserId $currentUser -RunLevel Highest

  Register-ScheduledTask -TaskName $scheduledTaskName -Action $Action -Trigger $Trigger -Principal $Principal -Description "Set Lockscreen Warning"
}

if ($getScheduledTaskName -eq $scheduledTaskName) {
  Unregister-ScheduledTask -TaskName $scheduledTaskName -Confirm:$False -ErrorAction SilentlyContinue| Out-Null
  ScheduleTaskForNextBoot
} else {
  ScheduleTaskForNextBoot
}

powershell -WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -File "C:\Windows\Setup\Scripts\set_lockscreen_wallpaper.ps1"