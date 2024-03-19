[CmdletBinding()]
param(
  [Parameter(Mandatory = $false)]
  [string] $scheduledTaskName
)

$getScheduledTaskName = (Get-ScheduledTask -TaskName $scheduledTaskName -ErrorAction SilentlyContinue).TaskName

if ($scheduledTaskName -eq $getScheduledTaskName) {
  Write-Host "Undoing....."
} else {
  Write-Host "Skeeping..."
}