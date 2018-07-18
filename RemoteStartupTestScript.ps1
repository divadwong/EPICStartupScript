# By DW
# 07/18/18
# This script resides on a RemoteServer. It is called by EPICStartupScript.ps1 that reside locally on every server.
# This can be used prior to making changes to a PVS golden image.
# It has same functions as EPICStartupScript.ps1 but copies are done from remote server as opposed to locally.
# Functions are CopyRemoteFile and CopyRemoteFolder

function copyremotefile($p, $f)
{
	if ($Prod)
	{
		try
		{		
			if (!(Test-Path C:\$p)){New-Item -Path C:\$p -ItemType Directory -Force -EA 0 | Out-Null} 
			Copy-Item "$RemoteScriptPath\Files\$p\$f.Prod" -Destination "C:\$p\$f" -Force -Confirm:$False -EA Stop
			WriteEventLog $ScriptName 'Information' "Remote Prod - Copied $p\$f.prod to C:\$p\$f"
		}
		catch
		{
			WriteEventLog $ScriptName 'Error' "Remote Prod - Failed to copy $p\$f.prod to C:\$p\$f"
		}		
	}
	else
	{
		try
		{	
			if (!(Test-Path C:\$p)){New-Item -Path C:\$p -ItemType Directory -Force -EA 0 | Out-Null}                                        
			Copy-Item "$RemoteScriptpath\Files\$p\$f.Test" -Destination "C:\$p\$f" -Force -Confirm:$False -EA Stop
			WriteEventLog $ScriptName 'Information' "Remote Test - Copied $p\$f.test to C:\$p\$f"
		}
		catch
		{
			WriteEventLog $ScriptName 'Error' "Remote Test - Failed to copy $p\$f.test to C:\$p\$f"
		}		
	}
} 
 
function copyremotefolder($p, $f)
{
	if ($Prod)
	{
		try
		{	
			#Delete folder if exist
			if (Test-Path C:\$p\$f){Remove-Item -Force -Recurse -Path C:\$p\$f -EA 0 | Out-Null}
			Copy-Item "$RemoteScriptPath\Files\$p\$f.Prod" -Destination "C:\$p\$f" -Force -Recurse -Confirm:$False -EA Stop
			WriteEventLog $ScriptName 'Information' "Remote Prod - Copied $p\$f.prod to C:\$p\$f"	
		}
		catch
		{
			WriteEventLog $ScriptName 'Error' "Remote Prod - Failed to copy $p\$f.prod folder to C:\$p\$f"
		}		
	}
	else
	{
		try
		{		
			if (Test-Path C:\$p\$f){Remove-Item -Force -Recurse -Path C:\$p\$f -EA 0 | Out-Null}
			Copy-Item "$RemoteScriptPath\Files\$p\$f.Test" -Destination "C:\$p\$f" -Force -Recurse -Confirm:$False -EA Stop
			WriteEventLog $ScriptName 'Information' "Remote Test - Copied $p\$f.test to C:\$p\$f"	
		}
		catch
		{
			WriteEventLog $ScriptName 'Error' "Remote Test - Failed to copy $p\$f.test to C:\$p\$f"
		}		
	}
} 

# Set New eventlog Source 
New-EventLog –LogName Application –Source $Scriptname -EA 0

#=============================================================================================
### Testing ### 
Writereg "HKLM:\SOFTWARE\Testing\ProxyDLL" 'Testing' 'RemoteProd' 'Remotetest'
copyremotefolder 'testing' 'xActiveDirectory'  

# Example of running something on one Server
#if ($Server -eq 'XXXXXXXDXXXXXX'){copyremotefile 'testing\Testfolder\Anotherlevel' 'Newfile.txt'}

# Example of running something on many servers. Serverlist TestServers.txt
$Serverlist = Import-CSV $RemoteScriptPath\TestServers.CSV
foreach ($s in $Serverlist)
{
	$s.servers
	if ($Server -eq $s.servers){copyremotefile 'testing\Testfolder\Anotherlevel' 'Newfile.txt'}
}		
### End Testing ###
#=============================================================================================
