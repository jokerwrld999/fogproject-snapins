Start-Transcript -Path C:\first_login.txt

$scheduledTaskName = "SetLockscreenWallpaper"
$getScheduledTaskName = (Get-ScheduledTask -TaskName $scheduledTaskName -ErrorAction SilentlyContinue).TaskName

function ScheduleTaskForNextBoot () {
  # param ($scheduledTaskName)
  Write-Host "Scheduling task $scheduledTaskName for next boot..." -ForegroundColor Blue

  # $ActionScript = '& {Invoke-Command -ScriptBlock ([scriptblock]::Create([System.Text.Encoding]::UTF8.GetString((New-Object Net.WebClient).DownloadData(''https://raw.githubusercontent.com/jokerwrld999/fogproject-snapins/main/tasks/system_setup/set_lockscreen_wallpaper.ps1''))))}'

  $ActionScript = "& ([ScriptBlock]::Create((irm https://raw.githubusercontent.com/jokerwrld999/fogproject-snapins/main/tasks/system_setup/set_lockscreen_wallpaper.ps1))) -scheduledTaskName $scheduledTaskName"

  $Action = New-ScheduledTaskAction -Execute "PowerShell" -Argument "-NoExit -ExecutionPolicy Bypass -NoProfile -Command `"$ActionScript`" -ArgumentList -scheduledTaskName `"$scheduledTaskName`" -WindowStyle hidden"

  $Trigger = New-ScheduledTaskTrigger -AtLogon

  $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
  $Principal = New-ScheduledTaskPrincipal -UserId $currentUser -RunLevel Highest

  Register-ScheduledTask -TaskName "SetLockscreenWallpaper" -Action $Action -Trigger $Trigger -Principal $Principal -Description "Set Lockscreen Warning"
}

 powershell -ExecutionPolicy Bypass -NoProfile -Command "Invoke-RestMethod 'https://github.com/jokerwrld999/fogproject-snapins/raw/main/tasks/system_setup/set_lockscreen_wallpaper.ps1' | Invoke-Expression"

if ($getScheduledTaskName -eq $scheduledTaskName) {
  Unregister-ScheduledTask -TaskName $scheduledTaskName -Confirm:$False -ErrorAction SilentlyContinue| Out-Null
  ScheduleTaskForNextBoot # -scheduledTaskName $scheduledTaskName
} else {
  ScheduleTaskForNextBoot #-scheduledTaskName $scheduledTaskName
}

Stop-Transcript