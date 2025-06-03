param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$patternName,

  [Parameter(Mandatory = $true, Position = 1)]
  [string]$patternSize
)

Write-Host "Generating ID for pattern: $patternName with size: $patternSize"

# Generate a unique ID based on the pattern name and size
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$uniqueId = "$patternName-$patternSize-$timestamp"

Write-Host "Generated ID: $uniqueId"
Write-Output $uniqueId

