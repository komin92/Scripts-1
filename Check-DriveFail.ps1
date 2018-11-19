$drives = Get-WmiObject -Class Win32_DiskDrive
foreach ($drive in $drives) {
	switch ($drive.Status) {
	{ ($_ -eq "Error") -or ($_ -eq "Degraded") -or ($_ -eq "Pred Fail") -or ($_ -eq "NonRecover") }
	{
		Write-Host  "A SMART error state has been logged on [Computer]: $_"
		$driveStatus = $_
		
		# Show to the user.
		[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
		[System.Windows.Forms.MessageBox]::Show("Hi there! `nYour hard drive has reported to Windows that it is probably failing. Please backup your data and see your school technician ASAP. Status reported was: $driveStatus")
	}
	default {
		Write-Host "Completed HDD Check"
	}
	}
}
Pause