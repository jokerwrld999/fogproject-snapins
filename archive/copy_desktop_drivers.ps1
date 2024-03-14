$networkShare = ""
$networkUser = ""
$networkPass = ''
$driversPath = "C:\Windows\Setup\Drivers\"
$driverChipsetDir = "$driversPath\Chipset"

if (!(Test-Path -Path $driverChipsetDir)) {
  net use $networkShare /user:$networkUser $networkPass
  Copy-Item -Path "$networkShare\Chipset" -Destination $driversPath -Recurse -Force
}
