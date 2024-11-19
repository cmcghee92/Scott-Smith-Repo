[CmdletBinding()]
Param (
    [string]$appid = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe',
    [string]$NotificationImage,
    [Parameter(Mandatory)]
    [string]$Title,
    [Parameter(Mandatory)]
    [string]$Message,
    [ValidateSet('alarm', 'reminder', 'incomingcall', 'default')]
    [string]$Type = 'default'
)
try {
    $null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
    $null = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]
} Catch {
    Write-Output "Cannot load Windows Runtime Classes. Please ensure that you are using Windows 10/11 System."
}
$NotificationTemplate = @"
<toast scenario="$Type">
    <visual>
            <binding template="ToastGeneric">
                <text>$Title</text>
                <text>$Message</text>
            </binding>
    </visual>
<actions>
    <action content="Play" activationType="protocol" arguments="C:\Windows\Media\Alarm01.wav" />
    <action content="Open Folder" activationType="protocol" arguments="file:///C:/Windows/Media" />
</actions>
</toast>
"@
$Documentxml = [Windows.Data.Xml.Dom.XmlDocument]::new()
$Documentxml.LoadXml($NotificationTemplate)
$CurrentToast = [Windows.UI.Notifications.ToastNotification]::new($Documentxml)
$Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appid)

try {
    $notifier.Show($CurrentToast)
    Write-Host "Toast Notification Sent Successfully." -ForegroundColor Green
} Catch {
    Write-Host "Error Sending Notification. Please Troubleshoot."
    Exit 1
}