param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$dailyRunCost,

  [Parameter(Mandatory = $true, Position = 1)]
  [string]$eaasEndDate
)

Write-Host "Calculating lifetime cost based on daily run cost: $dailyRunCost and end date: $eaasEndDate"

# Convert the daily run cost to a decimal
$dailyRunCostDecimal = [decimal]$dailyRunCost
# Convert the end date to a DateTime object
$endDate = [datetime]$eaasEndDate
# Get the current date
$currentDate = Get-Date
# Calculate the number of days until the end date
$runtimeDays = ($endDate - $currentDate).Days
# Calculate the lifetime cost
$lifetimeCost = $dailyRunCostDecimal * $runtimeDays

Write-Host "Calculated lifetime cost: $lifetimeCost"
Write-Output $lifetimeCost
