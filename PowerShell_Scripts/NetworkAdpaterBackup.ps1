#NetworkConfigurationBackup
#Gather Network Adapter Details: IP settings, DNS, Gateways
#Format for Backup: Save config to easily readable file
#Store with Timestamps: Timestamp in filename for versioning and historical record

# Network Configuration 

# 1. Configuration
$backupDirectory = "C:\Backups\NetworkConfig"
$backupFile = "NetworkConfig_$(get-date -format 'yyyyMMdd_HHmmss').txt
$backuppath = Join-Path -Path $backupDirectory -ChildPath $backupFile

# 2. Ensure Backup Directory Exists
if (!(Test-path -path $backupDirectory)) {
		New-item -itemtype Directory -path $backuppath | out-null
}

# 3. Collect Network Configuration Details
$networkconfig = @()
$networkadapters = Get-netadapter -physical | Where-Object { $_.Status -eq 'Up'}

foreach ($adapter in $networkadapters) {
		$adapterName = $adapter.Name
		$ipconfig = Get-netipconfiguration -InterfaceAlias $adapterName
		
		$networkconfig += "Adapter Name: $adapterName"
		$networkconfig += "IP Addresses: $($ipconfig.IPv4address | foreach-object { $_.IPaddress })"
		$networkconfig += "Subnet Masks: $($ipconfig.IPv4address | foreach-object { $_.PrefixLength })"
		$networkconfig += "Default Gateway: $($ipconfig.IPv4DefaultGateway.NextHop)"
		$networkconfig += "DNS Servers: $($ipconfig.DNSServer.ServerAddresses -join ', ')"
		$networkconfig += "----------------------------------------"
}
# 4. Save Configuration to File
$networkconfig -join "`n" | out-file -Filepath $backuppath

Write-Output "Network configuration backup saved to $backuppath"