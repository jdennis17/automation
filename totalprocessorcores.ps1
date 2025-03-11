# Get the total number of processors and cores
$processors = Get-WmiObject -Class Win32_Processor

# Get the number of processors (physical CPU sockets)
$totalProcessors = $processors.Count

# Get the total number of cores (logical processors across all CPUs)
$totalCores = ($processors | Measure-Object -Property NumberOfCores -Sum).Sum

# Get the number of logical processors (threads per physical core)
#$totalLogicalProcessors = ($processors | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum

# Output the results
Write-Host "Total Processors (CPUs): $totalProcessors"
Write-Host "Total Cores: $totalCores"
#Write-Host "Total Logical Processors: $totalLogicalProcessors"
