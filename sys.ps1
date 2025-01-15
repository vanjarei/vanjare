function Show-Menu {
    Clear-Host
    Write-Host "====================================="
    Write-Host "            Select an Action"
    Write-Host "====================================="
    Write-Host "Desktop Operations:"
    Write-Host "1. Shutdown the Computer"
    Write-Host "2. Restart the Computer"
    Write-Host "3. Open Windows Settings"
    Write-Host "4. Open Task Manager"
    Write-Host "5. Open File Explorer"
    Write-Host "6. View System Information"
    Write-Host "7. View Current Date and Time"
    Write-Host "8. Lock the Computer"
    Write-Host "9. Log Off Current User"
    Write-Host "====================================="
    Write-Host "Network Operations:"
    Write-Host "10. View IP Configuration"
    Write-Host "11. Ping a Host"
    Write-Host "12. View Active Network Connections"
    Write-Host "13. View Network Adapter Status"
    Write-Host "14. Flush DNS Cache"
    Write-Host "15. Check Wi-Fi Connection"
    Write-Host "16. Test Internet Speed"
    Write-Host "====================================="
    Write-Host "System Management:"
    Write-Host "17. View Disk Space Usage"
    Write-Host "18. View Running Processes"
    Write-Host "19. Check Windows Updates"
    Write-Host "20. Check Memory Usage"
    Write-Host "21. List Installed Programs"
    Write-Host "22. View Active Users"
    Write-Host "23. Schedule a Disk Cleanup"
    Write-Host "24. Enable or Disable a Service"
    Write-Host "====================================="
    Write-Host "Utility Commands:"
    Write-Host "25. Clear the Screen"
    Write-Host "26. Generate a Random Password"
    Write-Host "27. Exit"
    Write-Host "====================================="
}

# Desktop Operations
function Shutdown-Computer {
    $confirmation = Read-Host "Are you sure you want to shut down the computer? Type 'yes' to confirm"
    if ($confirmation -eq "yes") {
        Write-Host "Shutting down the computer in 30 seconds..."
        Shutdown.exe /s /f /t 30
    } else {
        Write-Host "Shutdown canceled."
    }
}

function Restart-Computer {
    $confirmation = Read-Host "Are you sure you want to restart the computer? Type 'yes' to confirm"
    if ($confirmation -eq "yes") {
        Write-Host "Restarting the computer in 30 seconds..."
        Shutdown.exe /r /f /t 30
    } else {
        Write-Host "Restart canceled."
    }
}

function Open-Settings {
    Write-Host "Opening Windows Settings..."
    Start-Process "ms-settings:"
}

function Open-TaskManager {
    Write-Host "Opening Task Manager..."
    Start-Process "taskmgr"
}

function Open-FileExplorer {
    Write-Host "Opening File Explorer..."
    Start-Process "explorer"
}

function View-SystemInfo {
    Write-Host "System Information:"
    systeminfo | Select-String "OS|Memory|Processor"
}

function View-DateTime {
    Write-Host "Current Date and Time: "
    Get-Date
}

function Lock-Computer {
    Write-Host "Locking the computer..."
    rundll32.exe user32.dll,LockWorkStation
}

function LogOff-User {
    Write-Host "Logging off the current user..."
    Shutdown.exe /l
}

# Network Operations
function View-IPConfig {
    Write-Host "IP Configuration:"
    ipconfig
}

function Ping-Host {
    $targetHost = Read-Host "Enter the hostname or IP address to ping"
    Write-Host "Pinging $targetHost..."
    ping $targetHost
}

function View-NetworkConnections {
    Write-Host "Active Network Connections:"
    netstat
}

function View-NetworkAdapterStatus {
    Write-Host "Network Adapter Status:"
    Get-NetAdapter
}

function Flush-DNSCache {
    Write-Host "Flushing DNS Cache..."
    ipconfig /flushdns
}

function Check-WifiConnection {
    Write-Host "Checking Wi-Fi Connection..."
    netsh wlan show interfaces
}

function Test-InternetSpeed {
    Write-Host "Testing internet speed..."
    Invoke-WebRequest -Uri "https://fast.com" -UseBasicParsing
}

# System Management
function View-DiskSpace {
    Write-Host "Disk Space Usage:"
    Get-PSDrive -PSProvider FileSystem
}

function View-RunningProcesses {
    Write-Host "Running Processes:"
    Get-Process
}

function Check-WindowsUpdates {
    Write-Host "Checking for Windows Updates..."
    Get-WindowsUpdate
}

function View-MemoryUsage {
    Write-Host "Memory Usage by Processes:"
    Get-Process | Sort-Object -Descending -Property WorkingSet | Select-Object -First 10 Name, @{Name="Memory(GB)";Expression={"{0:N2}" -f ($_.WorkingSet / 1GB)}}
}

function List-InstalledPrograms {
    Write-Host "Installed Programs:"
    Get-WmiObject -Class Win32_Product | Select-Object Name, Version
}

function View-ActiveUsers {
    Write-Host "Active Users on the System:"
    query user
}

function Schedule-DiskCleanup {
    Write-Host "Scheduling a Disk Cleanup..."
    Start-Process "cleanmgr" -ArgumentList "/sagerun:1"
}

function Manage-Service {
    Write-Host "Fetching active services..."
    $activeServices = Get-Service | Where-Object { $_.Status -eq 'Running' } | Select-Object -Property Name, DisplayName, Status
    $activeServices | Format-Table -AutoSize
    
    $serviceName = Read-Host "Enter the name of the service you want to manage"
    $action = Read-Host "Enter the action (Start, Stop, Restart)"
    
    switch ($action.ToLower()) {
        "start" {
            Write-Host "Starting service '$serviceName'..."
            Start-Service -Name $serviceName -ErrorAction Stop
            Write-Host "Service '$serviceName' started successfully."
        }
        "stop" {
            Write-Host "Stopping service '$serviceName'..."
            Stop-Service -Name $serviceName -ErrorAction Stop
            Write-Host "Service '$serviceName' stopped successfully."
        }
        "restart" {
            Write-Host "Restarting service '$serviceName'..."
            Restart-Service -Name $serviceName -ErrorAction Stop
            Write-Host "Service '$serviceName' restarted successfully."
        }
        default {
            Write-Host "Invalid action. Please specify Start, Stop, or Restart."
        }
    }
}

# Utility Commands
function Clear-Screen {
    Clear-Host
}

function Generate-RandomPassword {
    Write-Host "Generating a random password..."
    -join ((33..126) | Get-Random -Count 12 | % {[char]$_})
}

# Main script loop
do {
    Show-Menu
    $choice = Read-Host "Enter your choice (1-27)"

    switch ($choice) {
        # Desktop Operations
        1 { Shutdown-Computer }
        2 { Restart-Computer }
        3 { Open-Settings }
        4 { Open-TaskManager }
        5 { Open-FileExplorer }
        6 { View-SystemInfo }
        7 { View-DateTime }
        8 { Lock-Computer }
        9 { LogOff-User }

        # Network Operations
        10 { View-IPConfig }
        11 { Ping-Host }
        12 { View-NetworkConnections }
        13 { View-NetworkAdapterStatus }
        14 { Flush-DNSCache }
        15 { Check-WifiConnection }
        16 { Test-InternetSpeed }

        # System Management
        17 { View-DiskSpace }
        18 { View-RunningProcesses }
        19 { Check-WindowsUpdates }
        20 { View-MemoryUsage }
        21 { List-InstalledPrograms }
        22 { View-ActiveUsers }
        23 { Schedule-DiskCleanup }
        24 { Manage-Service }

        # Utility Commands
        25 { Clear-Screen }
        26 { Generate-RandomPassword }

        # Exit
        27 { Write-Host "Exiting... Goodbye!" }

        default {
            Write-Host "Invalid selection, please choose a valid option."
        }
    }

    if ($choice -ne 27) {
        Read-Host "Press Enter to continue..."
    }
} while ($choice -ne 27)

