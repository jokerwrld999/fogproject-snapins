function Disable-UserInput {
  $jobName = "BlockUserInput"
  
  # Persist blocking even if PowerShell window closes
  $blockInput = Add-Type -Name "UserInput" -PassThru -MemberDefinition @"
    [DllImport("user32.dll")]
    public static extern bool BlockInput(bool fBlockIt);
"@
  Start-Job -ScriptBlock { & $blockInput::BlockInput($true) }
}

Disable-UserInput | Out-Null