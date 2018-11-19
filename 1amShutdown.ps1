if(Get-ScheduledJob -ErrorAction SilentlyContinue | Where-Object Name -Like "NightlyShutdown"){
Write-Host 'No'}Else{
  $trigger = New-JobTrigger -Once -At "1am"
  $options = New-ScheduledJobOption -StartIfOnBattery -StartIfIdle -WakeToRun -ContinueIfGoingOnBattery
Register-ScheduledJob -Name NightlyShutdown -ScriptBlock `
{Stop-Computer -Force} -Trigger $trigger -ScheduledJobOption $options}