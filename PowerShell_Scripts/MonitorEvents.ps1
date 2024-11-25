$logfile = "C:\Temp\UserLoginAuditLog.txt"
if (!(Test-path -path $logfile)) {
    New-item -Path $logfile -ItemType File -Force
}
function Write-Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyyMMdd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logfile -Append
}
Write-Log "User Auditing Starting"

$eventids = @(4624, 4625, 4720, 4732, 4740, 4768, 4771)
# Id: 4624 -> Successful Login event
# Id: 4625 -> Failed Login attempt
# Id: 4720 -> User Account Creation
# Id: 4732 -> User added to Group
# Id: 4740 -> Account Lockout Event
# Id: 4768 -> Kerberos Authentication Failure
# Id: 4771 -> Authentication Ticket Request Failure

function Get-Audit {
        $events = Get-WinEvent -LogName Security -FilterXPath "*[System[EventID=$($eventids -join ' or EventID=' )]]" -MaxEvents 100
        foreach ($event in $events) {
            $eventid = $event.Id
            $eventtime = $event.TimeCreated
            $eventMessage = $event.$message

            if ($eventid -eq 4624) {
                $user = ($eventMessage -match "Account Name: \s+(\W+)") | Out-Null; $Matches[1]
                $ipaddress = ($eventMessage -match "Source Network Address:\s+(\S+)") | Out-Null; $Matches[1]
            }
            elseif ($eventid -eq 4625) {
                $user = ($eventMessage -match "Account Name: \s+(\w+)") | Out-Null; $Matches[1]
                Write-Log "Failed login attempt for user '$user' created at $eventTime."
            }
            elseif ($eventid -eq 4720) {
                $user = ($eventMessage -match "Account Name: \s+(\w+)") | Out-Null; $Matches[1]
                Write-Log "User account '$user' was created."
            }
            elseif ($eventid -eq 4732) {
                $user = ($eventMessage -match "Account Name: \s+(\w+)") | Out-Null; $Matches[1]
                Write-Log "User '$user' added to a group at $eventtime."
            }
            elseif ($eventid -eq 4740) {
                $user = ($eventMessage -match "Account Name: \s+(\w+)") | Out-Null; $Matches[1]
                Write-Log "User account '$user' was locked out at $eventtime"
            }
            elseif ($eventid -eq 4768) { 
                Write-Log "Kerberos authentication failure at $eventtime. This could indicate a possible security issue"
            }
            elseif ($eventid -eq 4771) {
                Write-Log "Failed authentication ticket request at $eventtime. Possible sercurity concern"
            }
            
        }
    }
While ($true) {
    Get-Audit
    Start-Sleep -Seconds 300
}