#Mark: Synopsis
<#Create Scheduled Task
Written by Mitchell Beare

This process collects user input and schedules that task with the operating system.
 #>

#Mark: Intialise$ErrorActionPreference = "Inquire"

#Mark: Functions
Function Define-Action{
    Write-Output 'Select a Task type from the following options'
    Write-Output '
    1: Powershell Command
    2: CMD Command
    3: Run a script
    '
    [string]$a = Read-Host 'Selection:'
    switch($a){
        '1'{$argument = Read-host 'Please input your command:'
            $script:action = New-ScheduledTaskAction -Execute powershell.exe -Argument $argument}

        '2'{$argument = Read-host 'Please input your command'
            $script:action = New-ScheduledTaskAction -Execute cmd.exe -Argument $argument
        }

        '3'{$scriptpath = Read-Host 'Please provide the path to script'
            $script:action = New-ScheduledTaskAction -Execute powershell.exe -Argument "-ExecutionPolicy Bypass $scriptPath"
        }

    }#End of switch $a
    cls
}#End Define-Action
Function Define-Trigger{
    Write-Output 'Select a Trigger for the Task from the following options:'
    Write-Output '
    1: Daily (Runs everyday at a set time)
    2: Weekly (Runs only on declared days of the week at a set time)
    3: At User Logon (any)
    4: At Machine Startup (any)
    5: One off (Schedule a once off command)
    '
    [string]$b = Read-Host 'Selection:'
    switch($b){

        '1'{[datetime]$time = Read-Host "What time will the task run? `n " 
            $script:trigger = New-ScheduledTaskTrigger -Daily -At $time}

        '2'{$days = Read-Host "What days will this task run? `n Input as a comma deliminated list e.g Monday, Tuesday"
            [datetime]$time = Read-Host "What time will the task run? `n "
            $script:trigger = New-ScheduledTaskTrigger -Weekly -At $time -DaysOfWeek $days }
                   
        '3'{$script:trigger = New-ScheduledTaskTrigger -AtLogOn}

        '4'{$script:trigger = New-ScheduledTaskTrigger -AtStartup}

        '5'{[string]$time = Read-Host "What time will the task run? `n "
            $script:trigger = New-ScheduledTaskTrigger -Once -At $time}
    }#End Switch $b
    cls
}#End Define-Trigger
Function Define-Options{
Write-Output "Now define job settings as a list `n Default: -StartIfOnBattery -StartIfIdle -WakeToRun -ContinueIfGoingOnBattery"

$selected = Read-Host " Select from the follow options or leave blank for defaults
   [-ContinueIfGoingOnBattery]
   [-DoNotAllowDemandStart]
   [-HideInTaskScheduler]
   [-IdleDuration <TimeSpan>]
   [-IdleTimeout <TimeSpan>]
   [-MultipleInstancePolicy <TaskMultipleInstancePolicy>]
   [-RequireNetwork]
   [-RestartOnIdleResume]
   [-RunElevated]
   [-StartIfIdle]
   [-StartIfOnBattery]
   [-StopIfGoingOffIdle]
   [-WakeToRun]
"
if($selected -eq ''){
$selected = '-StartIfOnBattery -StartIfIdle -WakeToRun -ContinueIfGoingOnBattery'
}
$script:options = invoke-expression "New-ScheduledJobOption $selected"
}#End Define-Options


#Mark: Main 
$host.ui.RawUI.WindowTitle = "Schedule Task on local machine"
Write-Output "
    Tasks scheduled will run as the user currently logged on.
    Please ensure you are logged on as a user with sufficent persmissions`n
    Default working directory is %windir%\system32 if your script requires a different working directory this MUST be specified beforehand.cls
    If you encounter any issues or have feature requests please contact mbear0@eq.edu.au"

do{
    $confirmed = $false
    [string]$taskname = Read-Host 'Please provide a descriptive taskname'
    Write-Output "You have written $taskname"
    $input = Read-Host "Is this Correct? Y/N"
    if($input -eq 'Y' -or $input -eq 'y' -or $input -eq 'yes'){
        $confirmed = $true 
    }
}while($confirmed -eq $false)


Define-Action
Define-Trigger
Define-Options
Register-ScheduledTask -TaskName $taskname -Action $action -Trigger $trigger
Pause