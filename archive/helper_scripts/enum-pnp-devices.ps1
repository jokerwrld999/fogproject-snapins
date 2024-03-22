# List of device IDs to check
$deviceIDs = @(
    "VEN_8086&DEV_A0E8",
    "VEN_8086&DEV_A0E9",
    "VEN_8086&DEV_A0EA",
    "VEN_8086&DEV_A0EB",
    "VEN_8086&DEV_A0C5",
    "VEN_8086&DEV_A0C6",
    "VEN_8086&DEV_A0D8",
    "VEN_8086&DEV_A0D9",
    "VEN_8086&DEV_43E8",
    "VEN_8086&DEV_43E9",
    "VEN_8086&DEV_43EA",
    "VEN_8086&DEV_43EB",
    "VEN_8086&DEV_43AD",
    "VEN_8086&DEV_43AE",
    "VEN_8086&DEV_43D8",
    "VEN_8086&DEV_43D9",
    "VEN_8086&DEV_1E22",
    "VEN_8086&DEV_06A4"
)

# Get the list of devices with problems
$problemDevices = pnputil /enum-devices /problem | Out-String

foreach ($id in $deviceIDs) {
    if ($problemDevices -match $id) {
        Write-Host "Device found: $id" -ForegroundColor Green
    } else {
        Write-Host "Device not found: $id" -ForegroundColor Red
    }
}
