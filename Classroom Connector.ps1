Function Write-Console{
  [Cmdletbinding()]
  Param([string]$Input)
  $txtConsole.Text +="`r`n" + $Input
}#End Write-Console
Function Start-Network{
  #This function reads through form input and creates an ad hoc network
  [cmdletbinding()]
  Param([string]$HostName,[string]$passkey)
   if([string]::IsNullOrEmpty($passkey)){
     netsh wlan set hostednetwork mode=allow ssid=$HostName
     $null = netsh wlan start hostednetwork
   }Else{
     netsh.exe wlan set hostednetwork mode=allow ssid=$HostName key=$passkey
     $null = netsh wlan start hostednetwork
   }
   $Adapters = Get-NetAdapter -InterfaceDescription "Microsoft Hosted Network Virtal Adapter"
   if($Adapters){
      Write-Console "Started Network $($HostName) `nPlease leave this window open while Until you are done."
   }Else{
    Write-Console "Failed to Start Netwok $HostName"
   }

}#End Function Create-Network

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()

#Define GUI

$Form                            = New-Object -TypeName system.Windows.Forms.Form
$Form.ClientSize                 = '350,250'
$Form.text                       = 'Classroom Connector'
$Form.TopMost                    = $false

$Label1                          = New-Object -TypeName system.Windows.Forms.Label
$Label1.text                     = 'Network Name:'
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object -TypeName System.Drawing.Point -ArgumentList (15,42)
$Label1.Font                     = 'Microsoft Sans Serif,10'

$Label2                          = New-Object -TypeName system.Windows.Forms.Label
$Label2.text                     = 'Password (Optional):'
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object -TypeName System.Drawing.Point -ArgumentList (11,86)
$Label2.Font                     = 'Microsoft Sans Serif,10'

$Button1                         = New-Object -TypeName system.Windows.Forms.Button
$Button1.text                    = 'Create'
$Button1.width                   = 60
$Button1.height                  = 30
$Button1.location                = New-Object -TypeName System.Drawing.Point -ArgumentList (92,128)
$Button1.Font                    = 'Microsoft Sans Serif,10'

$TextBox1                        = New-Object -TypeName system.Windows.Forms.TextBox
$TextBox1.multiline              = $false
$TextBox1.width                  = 100
$TextBox1.height                 = 20
$TextBox1.location               = New-Object -TypeName System.Drawing.Point -ArgumentList (170,40)
$TextBox1.Font                   = 'Microsoft Sans Serif,10'


$TextBox2                        = New-Object -TypeName system.Windows.Forms.TextBox
$TextBox2.multiline              = $false
$TextBox2.width                  = 100
$TextBox2.height                 = 20
$TextBox2.location               = New-Object -TypeName System.Drawing.Point -ArgumentList (170,90)
$TextBox2.Font                   = 'Microsoft Sans Serif,10'

$txtConsole                      = New-Object -TypeName system.Windows.Forms.TextBox
$txtConsole.Width = 200
$txtConsole.Height = 40
$txtConsole.Multiline = $true
$txtConsole.Location = New-Object -TypeName System.Drawing.Point -ArgumentList (170, 110)
$txtConsole.Font = 'Microsoft Sans Serif, 10'

$Form.controls.AddRange(@($Label1,$Label2,$Button1,$TextBox1,$TextBox2))
#End Define GUI

#Gui events 
$Button1.Add_Click({ Start-Network -networkname $TextBox1.Text.Trim() -passkey $TextBox2.Text.Trim() })
#End Gui events

$null = $Form.ShowDialog()



