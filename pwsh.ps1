
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "$snapinScriptPath\tasks\drivers\nvidia.ps1" -OutVariable logMessage

& ([ScriptBlock]::Create((irm "https://raw.githubusercontent.com/jokerwrld999/fogproject-snapins/main/tasks/system_setup/send_telegram_message.ps1"))) -botToken $botToken -chatID $chatID -logMessage $logMessage