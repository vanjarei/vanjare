# Full System Health Check Script with System Info and Report Download
# Author: GPT-Generated
# Description: Checks system health, provides a detailed report, and saves it to a file.

# Function to get system information
function Get-SystemInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    $bios = Get-CimInstance Win32_BIOS
    $cpu = Get-CimInstance Win32_Processor
    [PSCustomObject]@{
        ComputerName    = $env:COMPUTERNAME
        OS              = $os.Caption
        OSVersion       = "$($os.Version) ($($os.BuildNumber))"
        Manufacturer    = $os.Manufacturer
        BIOSVersion     = $bios.SMBIOSBIOSVersion
        Processor       = $cpu.Name
        Architecture    = $os.OSArchitecture
        BootTime        = $os.LastBootUpTime
    }
}

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
        TotalMemoryGB   = "$totalMem GB"
        FreeMemoryGB    = "$freeMem GB"
        UsedMemoryGB    = "$usedMem GB"
        UsagePercentage = [math]::round(($usedMem / $totalMem) * 100, 2)
    }
}

# Function to check disk space
function Get-DiskSpace {
    Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID, 
        @{Name="FreeSpaceGB"; Expression={[math]::round($_.FreeSpace / 1GB, 2)}}, 
        @{Name="TotalSpaceGB"; Expression={[math]::round($_.Size / 1GB, 2)}}, 
        @{Name="UsagePercentage"; Expression={[math]::round((($_.Size - $_.FreeSpace) / $_.Size) * 100, 2)}}
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

# Function to save the report
function Save-Report {
    param (
        [Parameter(Mandatory)]
        [string]$Content,
        [Parameter(Mandatory)]
        [string]$FilePath
    )
    try {
        $Content | Out-File -FilePath $FilePath -Encoding UTF8
        Write-Output "Report saved to $FilePath"
    } catch {
        Write-Output "Failed to save the report: $_"
    }
}

# Function to run the full system health check
function Run-SystemHealthCheck {
    $report = @()
    $report += "======== System Health Check ========"
    $report += "`n[System Information]"
    $report += (Get-SystemInfo | Format-List | Out-String)

    # CPU Usage
    $report += "`n[CPU Usage]"
    $report += (Get-CPUUsage | Format-Table -AutoSize | Out-String)

    # Memory Usage
    $report += "`n[Memory Usage]"
    $report += (Get-MemoryUsage | Format-Table -AutoSize | Out-String)

    # Disk Space
    $report += "`n[Disk Space]"
    $report += (Get-DiskSpace | Format-Table -AutoSize | Out-String)

    # Network Connectivity
    $report += "`n[Network Connectivity]"
    if (Test-Network) {
        $report += "Internet connectivity: Connected"
    } else {
        $report += "Internet connectivity: Not Connected"
    }

    # Event Log Errors
    $report += "`n[Recent Event Log Errors]"
    $errors = Get-EventLogErrors
    if ($errors) {
        $report += ($errors | Format-Table -AutoSize | Out-String)
    } else {
        $report += "No recent critical errors found in event logs."
    }

    # Running Processes
    $report += "`n[Top Running Processes by CPU Usage]"
    $report += (Get-RunningProcesses | Format-Table -AutoSize | Out-String)

    $report += "`n======== Health Check Complete ========"

    # Save the report
    $filePath = "$env:USERPROFILE\Desktop\SystemHealthReport.txt"
    Save-Report -Content ($report -join "`n") -FilePath $filePath

    Write-Output "Health check complete. The report has been saved to: $filePath"
}

# Run the health check
Run-SystemHealthCheck
