# NVIDIA SMI watchdog

— simple NVIDIA-SMI based software watchdog written in Powershell.

### Features
***
* Customizable list of performed actions when watchdog is triggered
* Customizable watchdog timers
* Prevents false-positive triggering (for example on miner start/switch)
* Write message to the Windows Event Log when watchdog is triggered

### Requirements
***
* Windows, tested on version `6.1.7601`
* Powershell, tested on version `5.x`
* NVIDIA-SMI, tested on version `390.77`

### Installation
***
1. Copy [watchdog.ps1] and [actions.bat] to the desired location
2. Create new Windows Task Scheduler task with following parameters:
	* Run with highest privileges: `true`
	* Begin task: `on a schedule`
	* Schedule: `One-time`
	* Repeat task every: `(choose appropriate duration from 5 to 10 minutes)` 
	* For a duration of `Indefinitely`
	* Stop task if it runs longer than: `false`
	* Expire: `false`
	* Enabled: `true`
	* Allow Start On Demand: `true`
	* Run only on AC power: `false`
	* Action: start a program
	* Action details: 
		* Command: `powershell.exe`	
		* Arguments: `-ExecutionPolicy Bypass "%path_from_p1%\watchdog.ps1 [optional_arguments]"`

	**OR** just import [Rig Utilization Monitoring.xml] task \(change UserId, schedule and arguments appropriately before use).
	
3. [Optional] Define your own actions in [actions.bat] \(performs system restart by default).
	
### Usage
***
Watchdog supports following arguments (all arguments are optional):

`watchdog.ps1 -path 'C:\Program Files\NVIDIA Corporation\NVSMI' -threshold 25 -cycleCount 3 -sleepInterval 30 -writeLog 1`

* **path** - path to `nvidia-smi.exe` executable file. 

	Default value: `'C:\Program Files\NVIDIA Corporation\NVSMI'`.
	
* **threshold** - GPU utilization for a single GPU (in percents), watchdog fires if utilization for ANY GPU falls below this value. 

	Default value: `25`.
	
* **cycleCount** - number of checks (to prevent false-positive triggering). 

	Default value: `3`.
	
* **sleepInterval** - sleep interval between checks (in seconds). 
	
	Default value: `30`.
	
* **writeLog** - write or not messages in Event Log when watchdog fires. Also see warning below. 
	
	Default value: `1` (write messages to log).

⚠️⚠️⚠️**Warning**⚠️⚠️⚠️

If you want to use Windows Event Log - you must register log source manually once before use with the following command:

`New-EventLog -source "Rig Monitoring" -logname Application`


###  License
***
NVIDIA SMI watchdog is released under an MIT license. See [LICENSE] for more information.

###  Author
***
[m3g0byt3]

[//]: #
[LICENSE]: 	<https://github.com/m3g0byt3/nvidia-smi-watchdog/blob/master/LICENSE.txt>
[watchdog.ps1]: <https://github.com/m3g0byt3/nvidia-smi-watchdog/blob/master/watchdog.ps1>
[actions.bat]: <https://github.com/m3g0byt3/nvidia-smi-watchdog/blob/master/actions.bat>
[Rig Utilization Monitoring.xml]: <https://github.com/m3g0byt3/nvidia-smi-watchdog/blob/master/Rig%20Utilization%20Monitoring.xml>
[m3g0byt3]: 	<https://github.com/m3g0byt3>

