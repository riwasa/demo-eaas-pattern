param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$lobFilePath,

  [Parameter(Mandatory = $true, Position = 1)]
  [string]$eaasStampFileRoot
)

Write-Host "Reading LOB parameters from file: $lobFilePath"
$json = Get-Content -Path $lobFilePath -Raw | ConvertFrom-Json

$eaasStampSize = $json.parameters.eaasStampSize.value
Write-Host "EaaS stamp size: $eaasStampSize"

$eaasEndDate = $json.parameters.eaasEndDate.value
Write-Host "EaaS end date: $eaasEndDate"

$eaasStampFilePath = "$eaasStampFileRoot/$($eaasStampSize.ToLower())-param.json"
Write-Host "Reading EaaS stamp file paramaters from file: $eaasStampFilePath"
$eaasStampJson = Get-Content -Path $eaasStampFilePath -Raw | ConvertFrom-Json

$dailyRunCost = $eaasStampJson.dailyRunCost
Write-Host "Daily run cost: $dailyRunCost"

Write-Host "Calculating lifetime cost based on daily run cost: $dailyRunCost and end date: $eaasEndDate"

# Convert the daily run cost to a decimal
$dailyRunCostDecimal = [decimal]$dailyRunCost

# Convert the end date to a DateTime object
$endDate = [datetime]$eaasEndDate

# Get the current date
$currentDate = Get-Date

# Calculate the number of days until the end date
$runtimeDays = ($endDate - $currentDate).Days
Write-Host "Runtime days until end date: $runtimeDays"

# Calculate the lifetime cost
$lifetimeCost = $dailyRunCostDecimal * $runtimeDays

Write-Host "Calculated lifetime cost: $lifetimeCost"
Write-Output $lifetimeCost
