# Daily System Health Check and Cleanup Script: Basic Details -> Needs More Tailoring

#System Health Check: Collect CPU, Memory, and Disk Usage
$cpuLoad = Get-CimInstance -ClassName Win32_Processor | Select-Object -ExpandProperty LoadPercentage
$memory = Get-CimInstance -ClassName Win32_OperatingSystem | 
	Select-Object @{Label="Total"; e={[math]::Round($_.TotalVisibleMemorySize / 1MB, 2)}},
                  @{Label="Free"; e={[math]::Round($_.FreePhysicalMemory / 1MB, 2)}}
$diskSpace = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" | 
	Select-Object DeviceID, 
				  @{Label="Total"; e={[math]::Round($_.Size / 1GB, 2)}},
                  @{Label="Free"; e={[math]::Round($_.FreeSpace / 1GB, 2)}}

#Critical Events (Last 24 Hours)
$criticalEvents = Get-WinEvent -FilterHashtable @{LogName='System'; Level=1; StartTime=(Get-Date).AddDays(-1)}

#File Cleanup
$TempPath = "$env:TEMP\*"
Remove-Item -Path $TempPath -Recurse -Force -ErrorAction SilentlyContinue

#Clear Browser Cache
$EdgeCachePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*"
Remove-Item -Path $EdgeCachePath -Recurse -Force -ErrorAction SilentlyContinue

#Clear Da' Bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

#Delete Old Files (older than 30 days) in Downloads
$downloadsPath = "$env:USERPROFILE\Downloads\*"
Get-ChildItem -Path $downloadsPath -Recurse | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Force -ErrorAction SilentlyContinue

#Report Creation:
$reportPath = "C:\Reports\DailySystemReport_$(Get-Date -Format 'yyyyMMdd').txt"
$diskusage = ($diskSpace | ForEach-Object { "Drive $($_.DeviceID): Total - $($_.Total) GB, Free - $($_.Free) GB" }) -join "`n"
$reportContent = @(
    "Daily System Health Check Report - $(Get-Date)",
    "----------------------------------------",
    "CPU Load: $($cpuLoad)%",
    "Total Memory: $($memory.Total) MB, Free Memory: $($memory.Free) MB",
    "Disk Usage:",
    $diskusage,
    "Critical Events (last 24 hours):",
    ($criticalEvents | ForEach-Object { "Event ID: $($_.Id) - Message: $($_.Message)" })
) -join "`n"

# Output report to file
$reportContent | Out-File -FilePath $reportPath

#Email the report (Needs SMTP server configuration) -> Needs Additional TS
#Send-MailMessage -To "admin@.com" -From "reporter@outlook.com" -Subject "Daily System Health Report" -Body (Get-Content $reportPath -Raw) -SmtpServer "smtp.example.com"
