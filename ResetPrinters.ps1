#Reset Print Spooler
#Simple script to clear print spooler.
#Written by mbear0 <mbear0@eq.edu.au

Write-Output -InputObject 'Cleaning up'
Write-Output -InputObject 'Stopping the Print Spooler.'
Stop-Service -Name Spooler -Force
Write-Output -InputObject 'Clearing the Spooler.'
Remove-Item -Path "$env:SystemRoot\System32\spool\PRINTERS\*.*"
Write-Output -InputObject 'Starting it back up.'
Start-Service -Name Spooler

Write-Output -InputObject 'Checking for old printers and cleaning them out.'
if (Get-Printer -Name \\eqsun1877019\P1877_SecurePrint){
  Remove-Printer -Name \\eqsun1877019\P1877_SecurePrint
}
Write-Output -InputObject 'Adding Current Printers'
Add-Printer -Name \\eqsun1877019\P1877_SecurePrint

Write-Output -InputObject "Closing Papercut and cleaning out it's cache."
$papercut = Get-Process -Name pc-client -ErrorAction SilentlyContinue
if($papercut){
  $papercut.Close()
  Start-Sleep -Seconds 5
  if(!$papercut.HasExited){
    $papercut | Stop-Process -Force
  }
}

Write-Output -InputObject 'Opening Papercut back up.'
Start-Process -FilePath  '\\eqsun1877019\PCClient\win\pc-client.exe'
