#Undurba CFT configuration script
#Written by mbear in 2018

# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
      if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
      $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
      Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
      Exit
   }
}

#Mark: Setup Variables
Get-Content ("\\"+(Get-ADDomainController).ipv4address+"\EQLOGON\ServerID.txt")|Foreach-Object{$var=$_.Split(':').trim();New-Variable -Name $var[0].replace(" ","") -Value $var[1]}

#Mark: Privacy Settings

# Privacy: Let apps use my advertising ID: Disable
Write-output -InputObject 'Turning off adds.'
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo -Name Enabled -Type DWord -Value 0

# Privacy: SmartScreen Filter for Store Apps: Disable
Write-Output -InputObject 'Disabling Smartscreen for Store apps.'
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost -Name EnableWebContentEvaluation -Type DWord -Value 0

# WiFi Sense: HotSpot Sharing: Disable
Write-Output -InputObject 'Disabling Hotspot sharing.'
Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting -Name value -Type DWord -Value 0
# WiFi Sense: Shared HotSpot Auto-Connect: Disable
Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots -Name value -Type DWord -Value 0


# Start Menu: Disable Bing Search Results
Write-Output -InputObject 'Disabling Bing'
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name BingSearchEnabled -Type DWord -Value 0

# Disable Telemetry (requires a reboot to take effect)
Write-Output -InputObject 'Disabling Microsoft Telemetry services.'
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection -Name AllowTelemetry -Type DWord -Value 0
Get-Service -Name DiagTrack,Dmwappushservice | Stop-Service | Set-Service -StartupType Disabled

#Mark: UI tweaks
Write-Output -InputObject 'Setting Look and Feel.'

# Change Explorer home screen back to "This PC"
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Type DWord -Value 1

# Disable Quick Access: Recent Files
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowRecent -Type DWord -Value 0

# Disable Quick Access: Frequent Folders
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowFrequent -Type DWord -Value 0

# Use the Windows 7-8.1 Style Volume Mixer
If (-Not (Test-Path -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC')) {
  $null = New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name MTCUVC
}
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC' -Name EnableMtcUvc -Type DWord -Value 0

# Mark: Windows 10 Metro App Removals

Get-AppxPackage -Name king.com.CandyCrushSaga | Remove-AppxPackage
# Bing Weather, News, Sports, and Finance (Money):
Get-AppxPackage -Name Microsoft.BingWeather | Remove-AppxPackage
Get-AppxPackage -Name Microsoft.BingNews | Remove-AppxPackage
Get-AppxPackage -Name Microsoft.BingSports | Remove-AppxPackage
Get-AppxPackage -Name Microsoft.BingFinance | Remove-AppxPackage 
# Xbox:
Get-AppxPackage -Name Microsoft.XboxApp | Remove-AppxPackage
# Windows Phone Companion
Get-AppxPackage -Name Microsoft.WindowsPhone | Remove-AppxPackage
# Solitaire Collection
Get-AppxPackage -Name Microsoft.MicrosoftSolitaireCollection | Remove-AppxPackage
# People
Get-AppxPackage -Name Microsoft.People | Remove-AppxPackage
# Groove Music
Get-AppxPackage -Name Microsoft.ZuneMusic | Remove-AppxPackage
# Movies & TV
Get-AppxPackage -Name Microsoft.ZuneVideo | Remove-AppxPackage
# OneNote
Get-AppxPackage -Name Microsoft.Office.OneNote | Remove-AppxPackage
# Photos
Get-AppxPackage -Name Microsoft.Windows.Photos | Remove-AppxPackage
# Sound Recorder
Get-AppxPackage -Name Microsoft.WindowsSoundRecorder | Remove-AppxPackage
# Mail & Calendar
Get-AppxPackage -Name microsoft.windowscommunicationsapps | Remove-AppxPackage
# Skype (Metro version)
Get-AppxPackage -Name Microsoft.SkypeApp | Remove-AppxPackage



#Mark: Install Airserver

#Mark: Configure Onenote

#Mark: Set powerplan
$power = Get-cimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'HighPerformance'"
Invoke-CimMethod -InputObject $power -MethodName Activate