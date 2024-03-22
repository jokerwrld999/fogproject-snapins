$getExecutionPolicy = Get-ExecutionPolicy -Scope LocalMachine
$executionPolicyName = "bypass"
if ($getExecutionPolicy -ne $executionPolicyName) {
  Set-ExecutionPolicy -ExecutionPolicy $executionPolicyName -Scope LocalMachine -Force *>$null
}