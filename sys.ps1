# Full System Health Check Script with Battery Health
# Author: GPT-Generated
# Description: Checks system health, including battery health, and saves a detailed report.

# Function to get enhanced system information
function Get-SystemInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    $bios = Get-CimInstance Win32_BIOS
    $cpu = Get-CimInstance Win32_Processor
    $memory = Get-CimInstance Win32_PhysicalMemory
    $disks = Get-CimInstance Win32_DiskDrive

    # Calculate total RAM in GB
    $totalRAM = [math]::round(($memory.Capacity | Measure-Object -Sum).Sum / 1GB, 2)
    $ramType = Switch ($memory.MemoryType) {
        20 { "DDR" }
        21 { "DDR2" }
        24 { "DDR3" }
        26 { "DDR4" }
        Default { "Unknown" }
    }

    [PSCustomObject]@{
        ComputerName    = $env:COMPUTERNAME
        OS              = $os.Caption
        OSVersion       = "$($os.Version) ($($os.BuildNumber))"
        Manufacturer    = $os.Manufacturer
        BIOSVersion     = $bios.SMBIOSBIOSVersion
        Processor       = $cpu.Name
        CPUCores        = $cpu.NumberOfCores
        TotalRAMGB      = "$totalRAM GB"
        RAMType         = $ramType
        Architecture    = $os.OSArchitecture
        BootTime        = $os.LastBootUpTime
        NumberOfDisks   = ($disks | Measure-Object).Count
        DiskTypes       = ($disks | Select-Object MediaType -Unique | ForEach-Object { $_.MediaType -join ", " }) -join ", "
    }
}

# Function to get battery health information
function Get-BatteryHealth {
    try {
        $battery = Get-CimInstance Win32_Battery
        if ($battery) {
            [PSCustomObject]@{
                BatteryStatus         = Switch ($battery.BatteryStatus) {
                    1 { "Discharging" }
                    2 { "Connected, Charging" }
                    3 { "Fully Charged" }
                    4 { "Low" }
                    5 { "Critical" }
                    6 { "Charging and High" }
                    7 { "Charging and Low" }
                    8 { "Charging and Critical" }
                    9 { "Undefined" }
                    10 { "Partially Charged" }
                    Default { "Unknown" }
                }
                EstimatedChargeRemaining = "$($battery.EstimatedChargeRemaining) %"
                EstimatedRunTimeMinutes  = "$($battery.EstimatedRunTime) minutes"
                DesignVoltage            = "$($battery.DesignVoltage / 1000) V"
            }
        } else {
            [PSCustomObject]@{
                BatteryStatus         = "No battery detected"
                EstimatedChargeRemaining = "N/A"
                EstimatedRunTimeMinutes  = "N/A"
                DesignVoltage            = "N/A"
            }
        }
    } catch {
        [PSCustomObject]@{
            BatteryStatus         = "Error retrieving battery information"
            EstimatedChargeRemaining = "N/A"
            EstimatedRunTimeMinutes  = "N/A"
            DesignVoltage            = "N/A"
        }
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

    # Battery Health
    $report += "`n[Battery Health]"
    $report += (Get-BatteryHealth | Format-List | Out-String)

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
