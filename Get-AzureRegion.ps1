param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$filePath
)

Write-Host "Getting Azure region from file: $filePath"

# Read the content of the file as JSON
$json = Get-Content -Path $filePath -Raw | ConvertFrom-Json

# Extract the Azure region from the JSON property
$azureRegion = $json.parameters.azureRegion.value

Write-Host "Azure region: $azureRegion"
Write-Output $azureRegion
