# Full System Health Check Script
# Author: GPT-Generated
# Description: Checks system health and provides a summary of key components

# Function to get CPU usage
function Get-CPUUsage {
    Get-CimInstance Win32_Processor | Select-Object Name, LoadPercentage
}

# Function to get memory usage
function Get-MemoryUsage {
    $mem = Get-CimInstance Win32_OperatingSystem
    $totalMem = [math]::round($mem.TotalVisibleMemorySize / 1MB, 2)
    $freeMem = [math]::round($mem.FreePhysicalMemory / 1MB, 2)
    $usedMem = $totalMem - $freeMem
    [PSCustomObject]@{
        TotalMemoryGB = "$totalMem GB"
        FreeMemoryGB = "$freeMem GB"
        UsedMemoryGB = "$usedMem GB"
        UsagePercentage = [math]::round(($usedMem / $totalMem) * 100, 2)
    }
}

# Function to check disk space
function Get-DiskSpace {
    Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID, @{Name="FreeSpaceGB"; Expression={[math]::round($_.FreeSpace / 1GB, 2)}}, @{Name="TotalSpaceGB"; Expression={[math]::round($_.Size / 1GB, 2)}}, @{Name="UsagePercentage"; Expression={[math]::round((($_.Size - $_.FreeSpace) / $_.Size) * 100, 2)}}
}

# Function to test network connectivity
function Test-Network {
    Test-Connection -ComputerName google.com -Count 1 -Quiet
}

# Function to check for recent critical errors in event logs
function Get-EventLogErrors {
    Get-EventLog -LogName System -EntryType Error -Newest 10
}

# Function to get running processes
function Get-RunningProcesses {
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, ID
}

# Summary function to combine all checks
function Run-SystemHealthCheck {
    Write-Output "======== System Health Check ========"

    # CPU Usage
    Write-Output "`n[CPU Usage]"
    Get-CPUUsage | Format-Table -AutoSize

    # Memory Usage
    Write-Output "`n[Memory Usage]"
    Get-MemoryUsage | Format-Table -AutoSize

    # Disk Space
    Write-Output "`n[Disk Space]"
    Get-DiskSpace | Format-Table -AutoSize

    # Network Connectivity
    Write-Output "`n[Network Connectivity]"
    if (Test-Network) {
        Write-Output "Internet connectivity: Connected"
    } else {
        Write-Output "Internet connectivity: Not Connected"
    }

    # Event Log Errors
    Write-Output "`n[Recent Event Log Errors]"
    $errors = Get-EventLogErrors
    if ($errors) {
        $errors | Format-Table -AutoSize
    } else {
        Write-Output "No recent critical errors found in event logs."
    }

    # Running Processes
    Write-Output "`n[Top Running Processes by CPU Usage]"
    Get-RunningProcesses | Format-Table -AutoSize

    Write-Output "`n======== Health Check Complete ========"
}

# Run the health check
Run-SystemHealthCheck
