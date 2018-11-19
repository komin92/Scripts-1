#Reset Print Spooler
#Simple script to clear print spooler.

Write-Output 'Stopping the Service'
Stop-Service -Name Spooler -Force
Write-Output 'Clearing spool.'
Remove-Item -Path "$env:SystemRoot\System32\spool\PRINTERS\*.*"
Write-Output 'Starting the Service'
Start-Service -Name Spooler