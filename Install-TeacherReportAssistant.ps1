#Mark: Declare Variables
$installpath = 'C:\Program Files (x86)'
$sourcepath = ''
$shortcutpath = "$env:Public\Desktop\Teacher Report Assistant.lnk"
$windowtitle = 'GriffinSS Software installer'

#Mark: Declare Functions
Function Install(){
#Copy files to program files
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
Copy-Item -Path "$ScriptDir\Teacher Report Assistant"  -Destination $installpath -Recurse
#Create a shortcut for the program
$AppLocation = "C:\Program Files (x86)\Teacher Report Assistant\trassist.exe"
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutpath)
$Shortcut.TargetPath = $AppLocation
$Shortcut.Description ="Teacher Report Assistant"
$Shortcut.WorkingDirectory ="C:\Windows\System32"
$Shortcut.Save()
#Set run as admin on the shortcut
$bytes = [System.IO.File]::ReadAllBytes($shortcutpath)
$bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
[System.IO.File]::WriteAllBytes($shortcutpath, $bytes)
}#End Install

#Mark: Main
$host.ui.RawUI.WindowTitle = $windowtitle
Write-Host 'Installing software'
Install
Write-Host 'Software has been successfully installed.' -ForegroundColor Green
Write-Host 'A shortcut has been placed on your desktop' -ForegroundColor Green

Pause