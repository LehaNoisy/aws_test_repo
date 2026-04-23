param (	
	[Parameter(Mandatory = $true)]
	[string]
	$collectionUrl,
	[Parameter(Mandatory = $true)]
	[string]
	$token,	
	[Parameter(Mandatory = $true)]
	[string]
	$poolName,	
	[Parameter(Mandatory = $true)]
	[string]
	$agentName,
	[Parameter(Mandatory = $true)]
	[string]
	$serviceAccount,	
	[Parameter(Mandatory = $true)]
	[string]
	$password
)

Write-Host "Register Agent at Azure DevOps now"
# AGENT SETUP with disabled AGENT SERVICE and SCHEDULED TASK:
& 'C:\agent\Config.cmd' --unattended --url "$collectionUrl" --auth pat --token "$token" --pool "$poolName" --agent "$agentName" --noRestart --AlwaysExtractTask --gituseschannel --replace --windowslogonaccount "$serviceAccount" --windowsLogonPassword "$password" --EnableServiceSidTypeUnrestricted false

Write-Host "Create Scheduled Task for Agent Execution with RunOnce mode now"
$runCmdPath="C:\agent\AgentExecutionLoop_With_RunOnce.ps1"
$actionOptionalArguments=$runCmdPath + " -AgentUser $serviceAccount"
$trigger = New-ScheduledTaskTrigger -AtStartup
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' $actionOptionalArguments
$principal = New-ScheduledTaskPrincipal -UserId $serviceAccount -LogonType Password -RunLevel Highest
$settingsSet = New-ScheduledTaskSettingsSet
# Set the Execution Time Limit to unlimited on all versions of Windows
$settingsSet.ExecutionTimeLimit = "PT0S"
$task = New-ScheduledTask -Trigger $trigger -Action $action -Settings $settingsSet -Principal $principal
$createdTask = Register-ScheduledTask -TaskName "Agent Loop RunOnce" -InputObject $task -User $serviceAccount -Password "$password"
$createdTask.Triggers.Repetition.Interval = "PT5M"
$createdTask | Set-ScheduledTask -User $serviceAccount -Password "$password"

Write-Host "Start Scheduled Task of Agent Loop now"
Start-ScheduledTask -TaskName "Agent Loop RunOnce" -AsJob

Write-Host "Configure AutoLogin for an initial login. AutoLogin will not be required later anymore."
$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
Set-ItemProperty $RegistryPath 'AutoAdminLogon' -Value "1" -Type String 
# Since we have two Restarts in Terraform execution (one additional restart seems to come from windows updates) 
Set-ItemProperty $RegistryPath 'AutoLogonCount' -Value "2" -Type DWORD 
Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "$serviceAccount" -type String 
Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "$password" -type String
 
Write-Warning "Restart is required for automatic login."
