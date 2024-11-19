#Service Health Check and Restart
#Define Critical Services
#Check Status
#Restart Stopped/Zombie Processes
#Generate a Log
$servicestomonitor = @(
		"Spooler",		#Print Spooler
		"wuauserv",		#Windows Update
		"MSSQLSERVER",	#SQL Server
		"W3SVC"			#World Wide Web Publishing Service (IIS)
	)
$logpath = "C:\Logs\ServiceHealthCheck_$(get-date -format 'yyyyMMdd').txt"
$logcontent = @(
		"Service Health Check Report - $(Get-Date)",
		"-----------------------------------------"
	)
foreach ($servicename in $servicestomonitor) {
	$service = Get-service -name $servicename -Erroraction SilentlyContinue
	if ($service) {
		$status = $service.status
		$logcontent += "Service: $servicename - Status: $status"
		if ($status -ne 'Running') {
			try {
				Start-Service -Name $servicename
				$logcontent += "Action: Service $servicename was stopped. Attempting to restart..."
			} catch {
				$logcontent += "Error: Failed to restart service $servicename. Error details: $_"
			}
		} else {
			$logcontent += "Action: No action needed. Service is running."
		}
		$logcontent += "-----------------------------------------"
	}
}
$logcontent -join "`n" | out-file -FilePath $logpath
Write-Output "Service Health Check Report generated at $logpath"
		