#System Admin Utility Script

function Write-Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyyMMdd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath "$env:TEMP\SysAdLog.txt" -Append
}
#Create Path 
if ((test-path -Path "$env:TEMP\SysAdLog.txt")) {
    New-Item -Path "$env:TEMP\SysAdLog.txt" -Force
}

Write-Log "Script started"

#General System Info
$computerinfo = Get-ComputerInfo
Write-Log "Computer Name: $($computerinfo.csname)"
Write-Log "OS Version: $($computerinfo.Osversion)"

#Top 5 Processes: Memory Usage
$topprocesses = Get-Process | Sort-Object WorkingSet -Descending | Select -First 5
Write-Log "Top 5 Processes by Memory Usage:"
foreach ($processes in $topprocesses) {
        Write-Log " $($processes.Name) - $([math]::Round($processes.WorkingSet / 1MB, 2)) MB"
}

#Check Disk Space
$disks = Get-WMIObject -Class Win32_LogicalDisk | Where { $_.Drivetype -eq 3}
foreach ($disk in $disks) {
        $freespacepercent = [math]::Round(($disk.Freespace / $disk.Size) * 100, 2)
        Write-Log "Disk $($disk.DeviceID) - Free Space: $freespacepercent%"
}

#List Recent Window's Updates
$recentupdates = Get-HotFix | sort InstalledOn -Descending | select -First 5
foreach ($update in $recentupdates) {
    Write-Log "Windows Update $($update.HotfixID) installed on $($update.InstalledOn)"
}

#Verify Internet Connectivity
$testconnection = Test-NetConnection -ComputerName "www.google.com" -InformationLevel Quiet
if ($testconnection) {
    Write-Log "Internet connection is active"
} else {
    Write-Log "No connection detected. Verify configuration"
}

#List active network connections *(Needs to Be Spruced Up)
$activeconnections = Get-NetTCPConnection | where state -eq 'Established'
if ($activeconnections) {
    Write-Log "Active Connections:"
     foreach ($connection in $activeconnections | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort | Sort-Object LocalAddress) {
        Write-Log " LocalAddress: $($connection.LocalAddress), LocalPort: $($connection.LocalPort), RemoteAddress: $($connection.RemoteAddress), RemotePort: $($connection.RemotePort)"
     }
} else {
    Write-Log "No Active Connections."
}
#if (activeconnections) {activeconnections | foreach-object { $_.LocalAddress, $_.LocalPort, $_.RemoteAddress, $_.RemotePort} | Sort-Object -Property LocalAddress})
#Check Firewall Status
$firewallstatus = Get-NetFirewallProfile | select Name, Enabled
foreach ($rule in $firewallstatus) {
        Write-Log "Firewall Profile $($rule.Name) is $(if($rule.Enabled) {'enabled'} else {'disabled'})"
}
Write-Log "Script Complete"

Get-content "$env:TEMP\SysAdLog.txt"
