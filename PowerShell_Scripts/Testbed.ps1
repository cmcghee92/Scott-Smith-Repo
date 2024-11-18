param (
    [Parameter(Mandatory=$true)]
    [string]$Message,

    [Parameter(Mandatory=$false)]
    [string]$ImagePath
)
$ToastXml = @"
<toast>
    <visual>
        <binding template="ToastGeneric">
            <text>$Message</text>
            $(if ($ImagePath) { "<image placement='appLogoOverride' src='$ImagePath'/>" })
        </binding>
    </visual>
</toast>
"@
$Template = ([Windows.Data.Xml.Dom.XmlDocument]).new($ToastXml)
$Template.LoadXml($ToastXml)

# Get the toast notification manager for the current user
$Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppId)
$Notification = [Windows.UI.Notifications.ToastNotification]::new($Template)

# Show the toast notification
$Notifier.Show($Notification)