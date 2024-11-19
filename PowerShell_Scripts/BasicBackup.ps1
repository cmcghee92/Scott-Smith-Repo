#Day_38:Basic_Backup_script
#Specify Folders to Backup: Define
$reservesupply = @(
		"$env:USERPROFILE\Documents"
		"$env:USERPROFILE\Desktop"
)
$reservelocation = "G:\Backups"
$reserveexpiration = 30
if (!(test-path $reservelocation)) {
	New-Item -itemtype Directory -path $reservelocation
}
#Create Daily Archive: Compress folders with zip and specify timestamped name
$timestamped = get-date -format 'yyyyMMdd'
$reservepath = "DailyBackup_$($timestamped).zip"
$backupjoin = Join-Path -path $reservelocation -childpath $reservepath

#Organize: Backup Directory
foreach ($files in $reservesupply) {
	if (test-path -path $files) {
		compress-archive -path $files -Update -Destinationpath $backupjoin
	} else {
		Write "Warning: $files does not exist, skipping."
	}
}

#Cleanup: Delete older backups after 30 days
$expirationtime = (get-date).adddays(-$reserveexpiration)
gci -path  $reservelocation -filter "DailyBackup__*.zip" | Where-Object {
			$_.lastwritetime -lt $expirationtime
		} | foreach-object {
			remove-item -path $_.Fullname -force
			Write "Deleting Expired Goods"
	}
Write "Expired Reserves drained. Reserves from the last '$reserveexpiration' days are left."