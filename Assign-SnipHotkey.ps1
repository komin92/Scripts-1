#Bind Snipping Tool to a Shortcut
#Written by Mitchell Beare 2018
$appName = "SnippingTool"
if(Test-Path "C:\Users\$env:USERNAME\Desktop\$appName.lnk"){
  Write-Output "Shorcut already exists"
}Else{
$wshshell = new-object -comobject wscript.shell
$arguments = " /clip"
$shortCut = $wshShell.CreateShortCut("C:\Users\$env:USERNAME\Desktop\$appName.lnk")
$shortCut.TargetPath = $appName
$shortCut.Description = "Lanch $appName"
$shortCut.HotKey = "CTRL+F12"
$shortCut.Arguments = $arguments
$shortCut.Save()
Write-Output "Shortcut has been created."
}

Pause