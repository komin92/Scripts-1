<#   
Script to delete or list old files in a folder

Written by Mitchell Beare
#>


Write-Output
$path = Read-Host 'What is your starting directory?'
$daysback = Read-Host 'How many days old?'
$daysback = '-' + $daysback
$currentdate = Get-Date
$datetodelete = $currentdate.AddDays($daysback)
Get-ChildItem $path -Recurse | where-object {$_.LastWriteTime -lt $datetodelete } | Remove-Item