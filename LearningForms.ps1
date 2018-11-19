#Mark: Include require Assemblies
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Windows.Forms.Application]::EnableVisualStyles()

#Create a new object that is our form.
$Form = New-Object System.Windows.Forms.Form
$Form.Size = New-Object System.Drawing.Size(400,200)
$Form.MaximizeBox = $true
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = "Fixed3D"
$Form.Text = "Window Title"
$Form.AutoSize = $true
$Form.AutoSizeMode = "GrowAndShrinks"


#Give the form an Icon
#$Formicon = New-Object System.Drawing.icon ("\\Path to icon")
#$Form.Icon = $Formicon

#Create a label on the form
$Label = New-ObjecT System.Windows.Forms.Label
$Label.Text = "This is My label text"
$Label.AutoSize = $true
$Label.Location = New-Object System.Drawing.Size(75,50)
$Font = New-Object System.Drawing.Font("Garamond",15,[System.Drawing.FontStyle]::Bold)
$Form.Font = $Font
$Form.Controls.Add($Label)

#Create a Button on the form
$Button = New-Object System.Windows.Forms.Button
$Button.Location = New-Object System.Drawing.Size(140,80)
$Button.Size = New-Object System.Drawing.Size(100,30)
$Button.Text = "Close"
$Button.Add_Click({$Form.Close()})
$Form.Controls.Add($Button)

$Buttonprocess = New-Object System.Windows.Forms.Button
$Buttonprocess.Location = New-Object System.Drawing.Size(140,120)
$Buttonprocess.Size = New-Object System.Drawing.Size(100,30)
$Buttonprocess.Text = "Processes"
$Buttonprocess.Add_Click(
{
Get-Process | Out-GridView
}
)
$Form.Controls.Add($Buttonprocess)


#Finalise creation of the form and display it on the screen.
$Form.ShowDialog()
Return 0