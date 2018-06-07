# !!!!!!!!!!!! WARNING !!!!!!!!!!!!
# Register log source manually once before use:
# `New-EventLog -source "Rig Monitoring" -logname Application`
# !!!!!!!!!!!! WARNING !!!!!!!!!!!!

param (
	[String]$_path			= "\NVIDIA Corporation\NVSMI\",
	[String]$path			= (Get-ChildItem -path Env:ProgramFiles).value + $_path,
	[Int]$threshold			= 25,
	[Int]$cycleCount		= 3,
	[Int]$sleepInterval		= 30,
	[Int]$writeLog			= 1
)

[String]$smiExecutableName	= "\nvidia-smi.exe"
[String]$fullPath			= $path + $smiExecutableName
[String]$actionBatFileName	= "actions.bat"
[String]$queryArg       	= "--query-gpu=utilization.gpu"
[String]$formatArg      	= "--format=csv,noheader"
[String]$delimiter      	= " %"
[String]$replacement    	= ""
[String]$separator      	= " "
[String]$logName			= "Application"
[String]$logSource			= "Rig Monitoring"
[Int]$logEventID			= 9999
[Int]$logCategory			= 1
[String]$logEntryType		= "Error"
[String]$logMessage			= "Restarting rig due to low GPU utilization."
[String]$errorMessage		= "Unable to get output from NVSMI, aborting."

function Action-Required {
	Try {
		$output = & "$fullPath" $queryArg $formatArg
	}
	
	Catch {
		Write-Host $errorMessage
		break
	}
	
	$output = $output -replace $delimiter, $replacement 
	$output = $output.split($separator)

	foreach ($utilization in $output) {
		$utilization = [Int]$utilization
		
		if ($utilization -lt $threshold) {
			# Early exit and return `True` if low utilization detected for ANY GPU
			Write-Output 1
			break
		}
	}
	# Return `False` if GPU utilization is OK for ALL GPUs
	Write-Output 0
}

function Perform-Action {
	if ($writeLog -eq 1) {
	 	Write-EventLog -logname $logName -source $logSource -eventID $logEventID -entrytype $logEntryType -message $logMessage -category $logCategory
	}
	$currentDir = $MyInvocation.PSScriptRoot
	& "$currentDir\$actionBatFileName"
    break
}

For ($i=1; $i -le $cycleCount; $i++) {
	$isActionNeeded = Action-Required
	
	if ($isActionNeeded -eq 0) {
		# Early exit if GPU utilization is OK for ALL GPUs at the first cycle
		Write-Host "All fine, nothing to do here, exiting."
		break
	}

	if ($isActionNeeded -and $i -eq $cycleCount) {
		# If this is the last cycle and the action is still required - perform action
		Write-Host "Something definitely wrong, performing required action!"
		Perform-Action
		break
	} else {
		# ...else sleep for given amount of time for the another cycle
		Write-Host "Looks like something is wrong, waiting for the confirmation..."
		Start-Sleep -s $sleepInterval
	}
}
