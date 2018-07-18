# Setup the Golden Image with a task
# copies epicstartupscript to c:\windows\system32
# And Enables RSAT
$location = Split-Path $PSCommandPath -Parent
Copy-Item -Path $location\epicstartupscript.* -Destination C:\windows\system32
$action = New-ScheduledTaskAction -Execute 'c:\windows\system32\EpicStartupScript.vbs'
$trigger =  New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -Action $action -Trigger $trigger -User 'NT AUTHORITY\SYSTEM' -TaskName "EpicStartupScript" -Description "Script that starts at bootup to help configure PVS image to the correct environment (Dev, QA, Prod)"
Add-WindowsFeature RSAT-AD-PowerShell
