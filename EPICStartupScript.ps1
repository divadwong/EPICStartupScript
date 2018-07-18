# Startup Script for EPIC PVS Servers
# To help configure PVS image to the right environment
#######################################################

function WaitforNetwork
{ #This waits up to 5 minutes for network, checking every 10 seconds.
	For ($i=1; $i -le 30; $i++)
	{
		# wait 10 second intervals to check for network
		Start-Sleep -s 10
		if (Test-Path $RemoteScriptPath\EpicStartupScript.ps1){return}
	}
}

function WriteEventLog($Source, $EntryType, $Message)
{
	Write-EventLog –LogName Application –Source $Source –EntryType $EntryType –EventID 10 -Category 0 –Message $Message
}

function copyfile($p, $f)
{
	if ($Prod)
	{
		try
		{	
			Copy-Item "$p\$f.Prod" -Destination "$p\$f" -Force -Confirm:$False -EA Stop
			WriteEventLog $ScriptName 'Information' "Prod - Copied $p\$f.prod to C:\$p\$f"
		}
		catch
		{
			WriteEventLog $ScriptName 'Error' "Prod - Failed to copy $p\$f.prod to C:\$p\$f"
		}		
	}
	else
	{
		try
		{	
			Copy-Item "$p\$f.Test" -Destination "$p\$f" -Force -Confirm:$False -EA Stop
			WriteEventLog $ScriptName 'Information' "Test - Copied $p\$f.prod to C:\$p\$f"
		}
		catch
		{
			WriteEventLog $ScriptName 'Error' "Test - Fail to copy $p\$f.prod to C:\$p\$f"
		}		
	}
}

function copyfolder($p, $f)
{
	if ($Prod)
	{
		try
		{	
			if (Test-Path $p\$f){Remove-Item -Force -Recurse -Path $p\$f -EA 0 | Out-Null}
			Copy-Item "$p\$f.Prod" -Destination "$p\$f" -Force -Recurse -Confirm:$False -EA Stop
			WriteEventLog $ScriptName 'Information' "Prod - Copied $p\$f.prod to C:\$p\$f"	
		}
		catch
		{
			WriteEventLog $ScriptName 'Error' "Prod - Fail to copy $p\$f.prod to C:\$p\$f"	
		}		
	}
	else
	{
		try
		{		
			if (Test-Path $p\$f){Remove-Item -Force -Recurse -Path $p\$f -EA 0 | Out-Null}
			Copy-Item "$p\$f.Test" -Destination "$p\$f" -Force -Recurse -Confirm:$False -EA Stop
			WriteEventLog $ScriptName 'Information' "Test - Copied $p\$f.prod to C:\$p\$f"	
		}
		catch
		{
			WriteEventLog $ScriptName 'Error' "Test - Fail to copy $p\$f.prod to C:\$p\$f"	
		}		
	}
}

function Writereg($RegKey, $RegName, $RegProdValue, $RegTestValue)
{
	if ($envir -eq 'p')
	{
		try
		{	
			Set-ItemProperty -path $RegKey -name $RegName -value $RegProdValue
			WriteEventLog $ScriptName 'Information' "$RegKey\$RegName set to $RegProdValue"
		}
		catch
			{WriteEventLog $ScriptName 'Error' "$RegKey\$RegName failed set to $RegProdValue - Failed"}
	}		
	else
	{
		try
		{	
			Set-ItemProperty -path $RegKey -name $RegName -value $RegTestValue
			WriteEventLog $ScriptName 'Information' "$RegKey\$RegName set to $RegTestValue"
		}
		catch
			{WriteEventLog $ScriptName 'Error' "$RegKey\$RegName failed set to $RegTestValue - Failed"}	
	}		
}	

$ScriptName = "StartupScript"
$Server=$env:computername
$envir = $Server[7]
New-EventLog –LogName Application –Source $Scriptname -EA 0

switch ($envir){
"D" {
	$RemoteScriptPath = "\\YourServer\startupscript$"
	$RemoteScriptName = "RemoteStartupScript"
	$RemoteTestScriptName = "RemoteStartupTestScript"
	$Prod = $False
	WriteEventLog $ScriptName 'Information' 'DEV Server Detected.'
	Write-Verbose "Hi from Dev"
  }
"Q" {
	$RemoteScriptPath = "\\YourServer\startupscript$"
	$RemoteScriptName = "RemoteStartupScript"
	$RemoteTestScriptName = "RemoteStartupTestScript"
	$Prod = $False
	WriteEventLog $ScriptName 'Information' 'QA Server Detected.'
	Write-Verbose "Hi from QA"
  }
"P" {
	$RemoteScriptPath = "\\YourServer\startupscript$"
	$RemoteScriptName = "RemoteStartupScript"  
	$RemoteTestScriptName = "RemoteStartupTestScript"
	$Prod = $True
	WriteEventLog $ScriptName 'Information' 'Prod Server Detected.'
	Write-Verbose "Hi from Prod"
	}
default {
	# write to eventlog that something is wrong the server 8th char isn't D Q or P for some reason
	WriteEventLog $ScriptName 'Error' "Servername $Server does not correspond to DEV, QA or Prod Environments."
	Write-Verbose "FUBAR"
	Exit
  }
}
#=====================================================================================
# Usage for Copyfile <path> <file>
# there should be a 2 files in the folder with that filename and .test and .prod extensions after it
# in Epicintegrations.config example, there's file named epicintegrations.config.test and epicintegrations.config.prod
copyfile 'C:\Program Files (x86)\Hyland\Integration for Epic\v83\SAS' 'Epicintegrations.config'
copyfile 'C:\Program Files (x86)\Hyland\Integration for Epic\Viewer' 'Epicintegrations.config'

# Usage Copyfolder <ParentFoldername> <LeafFoldername>  ### the existing LeafFoldername should be xyz.prod and xyz.test
# in below example there should be an existing folder named c:\program files (x86)\epicstuff.prod and c:\program files (x86)\epicstuff.test
# and depending on the environment, either test or prod will be copied as EpicStuff
#copyfolder 'c:\Program Files (x86)' 'epicstuff'

# WriteReg $RegKey, $RegName, $RegProdvalue, $RegTestvalue
#Writereg "HKLM:\SOFTWARE\SomeKey\Test" 'Testing' 'Prod' 'Test'

#=====================================================================================
#-------------------------------------------------------------------------------------
# Below is for running one-off updates. Servername has to be in the appropriate group 
#-------------------------------------------------------------------------------------
WaitforNetwork
$RemoteScriptGroup = "EpicRemoteStartupScript"
$RemoteTestScriptGroup = "EpicRemoteTestStartupScript"
$InProdgroup = Get-ADGroupMember -identity $RemoteScriptGroup
$InTestgroup = Get-ADGroupMember -identity $RemoteTestScriptGroup
if (($InProdgroup.name -contains $Server) -And ($Envir -eq 'p'))
{
	# Run Remote Script
	$Scriptname = $RemoteScriptName
	. $RemoteScriptPath\$RemoteScriptName.ps1
}
if ($InTestgroup.name -contains $Server)
{
	# Run Remote Test Script
	$Scriptname = $RemoteTestScriptName
	. $RemoteScriptPath\$RemoteTestScriptName.ps1
}
