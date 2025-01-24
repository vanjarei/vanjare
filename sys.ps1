function Check-SystemHealth {
    # System Information
    Write-Host "System Information:"
    systeminfo | Select-String "OS|Memory|Processor"
    
    # CPU Health
    Write-Host "`nCPU Health:"
    Get-WmiObject -Class Win32_Processor | Select-Object Name, LoadPercentage
    
    # Memory Usage
    Write-Host "`nMemory Usage:"
    Get-WmiObject -Class Win32_OperatingSystem | Select-Object TotalVisibleMemorySize, FreePhysicalMemory
    
    # Disk Space and Health
    Write-Host "`nDisk Space Usage:"
    Get-PSDrive -PSProvider FileSystem | Format-Table -Property Name, @{Name="Used(GB)";Expression={"{0:N2}" -f ($_.Used/1GB)}}, @{Name="Free(GB)";Expression={"{0:N2}" -f ($_.Free/1GB)}}, @{Name="Total(GB)";Expression={"{0:N2}" -f ($_.Used + $_.Free)/1GB}}} 

    # Network Health
    Write-Host "`nNetwork Status:"
    Get-NetAdapter | Format-Table -Property Name, Status, LinkSpeed

    # Battery Health (if applicable)
    if (Test-Path "C:\Windows\System32\Batterystats.bin") {
        Write-Host "`nBattery Health:"
        Get-WmiObject -Class Win32_Battery | Select-Object EstimatedChargeRemaining, BatteryStatus
    }

    # Check for Windows Updates
    Write-Host "`nWindows Update Status:"
    Get-WindowsUpdate | Format-Table -Property Title, Date
    
    # System Event Logs (Errors)
    Write-Host "`nRecent Critical System Errors:"
    Get-WinEvent -LogName System -Level Error | Select-Object TimeCreated, Message | Format-Table -AutoSize
}

# Run the health check
Check-SystemHealth
