[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string] $botToken,
  [Parameter(Mandatory = $true)]
  [string] $chatID,
  [Parameter(Mandatory = $false)]
  [string] $logMessage
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$messageText = "✅ Snapins on host *$(hostname)* completed. Check your log: \n $logMessage" + "Heh, your log is: $logMessage" + $LogCommandHealthEvent

Invoke-RestMethod -Uri "https://api.telegram.org/bot$($botToken)/sendMessage?chat_id=$($chatID)&text=$($messageText)&parse_mode=markdown"