Write-Host "Fetching Printers"
$NetworkPrinters = Get-WmiObject -Class Win32_Printer | Where-Object{$_.Network}
If ($NetworkPrinters -ne $null){
    Try{
		Foreach($NetworkPrinter in $NetworkPrinters){
			$NetworkPrinter.Delete()
			Write-Host "Successfully deleted the network printer:" + $NetworkPrinter.Name -ForegroundColor Green	
		}
	}Catch{
		Write-Host $_

		}
	}
	Else{
	    Write-Warning "Cannot find network printers in the current environment."
	}

Write-Host "Attempting to reinstall printers"
#Run Printer Script
Try{
    Powershell.exe -executionpolicy remotesigned -File "$env:EQLOGONSERVER\NETLOGON\Set-EQPrinters.ps1"
}Catch{
    Write-Host $_
}
Write-Host "Successfully reinstalled printers" -ForegroundColor Green