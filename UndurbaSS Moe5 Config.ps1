#Undurba SS MOE 5 Desktop Setup Script
#Written by mbear0

Function Configure-PowerPlan{
  #This function configures a custom high performance power plan to
  Try{
      $HighPerf = powercfg -l | ForEach-Object{
        if($_.contains('High performance')) {
          $_.split()[3] 
        } 
      }
      $CurrPlan = $(powercfg -getactivescheme).split()[3]
      if ($CurrPlan -ne $HighPerf){
        powercfg -setactive $HighPerf
      }

  } Catch {
    Write-Warning -Message 'Unable to set power plan to high performance.'
  }
}#End Configure-PowerPlan

Function Install-Firefox{
  # This function installs Mozilla Firefox from a network share
  if(Test-Connection -ComputerName 10.113.92.1 -Count 1 -Quiet){
    #Connect to site fileshare
    try{
      New-PSDrive -Name Temp -Root '\\eqsun1877001\CDApps$' -PSProvider FileSystem
    } Catch{
      Write-Warning -Message 'Failed to connect to fileshare \\eqsun1877001\CDApps$'
    }
    
    #Copy installer locally. 
    try{
      Copy-Item  -Path 'Temp:\Mozilla Firefox\Installer.msi' -Destination "$env:HOMEDRIVE\Temp"
    } Catch{
      Write-Warning -Message 'Failed to copy Installer to machine.'
      Remove-PSDrive -Name Temp
    }
    
    #Run the installer
    try{
      Invoke-Command "$env:HOMEDRIVE\Temp\Installer.msi -ms"
    } Catch{
      Write-Warning "Failed to install Mozilla Firefox"
      Remove-PSDrive -Name Temp
    }
    
    #Set as default Browser
    
  }Else {
    Write-Warning -Message 'Failed to Contact eqsun1877001'
  }

}

