#Remove-PrinterDriver
#Stops the spools, allows removal of drivers then brings spool back up.


#Get driver and remove associated devices
Write-Output "Printing list of installed Print Drivers"
Get-PrinterDriver | Select-Object -Property Name | Format-table
$driver = Read-Host 'Please input Driver name exactly as it appears above.'

#Pause Winprint
Stop-Service -Name "Spooler"
Rename-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Environments\Windows x64\Print Processors\winprint" -NewName winprintOLD
Start-Service -Name "Spooler"

#Delete Driver
Write-Output 'Deleting Printer Driver'
Remove-PrinterDriver -Name $driver

#Clear Print Spooler to finalise uninstall.
Write-Output 'Clearing print Spooler.'
Stop-Service -Name Spooler -Force
Remove-Item -Path "$env:SystemRoot\System32\spool\PRINTERS\*.*"
Rename-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Environments\Windows x64\Print Processors\winprintOLD" -NewName winprint
Start-Service -Name Spooler
Write-Output 'Finished'
Pause