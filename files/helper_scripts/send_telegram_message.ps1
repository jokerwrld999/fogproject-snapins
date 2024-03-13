[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string] $botToken,
  [Parameter(Mandatory = $true)]
  [string] $chatID
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$messageText = "✅ Snapins on host *$(hostname)* completed."

Invoke-RestMethod -Uri "https://api.telegram.org/bot$($botToken)/sendMessage?chat_id=$($chatID)&text=$($messageText)&parse_mode=markdown"