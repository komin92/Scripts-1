#Moe Remote Assistance Tool
#Written by mbear0

#Mark: Load required assemblies
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Windows.Forms.Application]::EnableVisualStyles()

#Mark: Intialize variables
[string]$compname = ""


#Mark: Define Functions
Function UpdateConsole($text){
    $consoleTextbox.Text = $consoleTextbox.Text + "`n$text"
}
Function establishSession{
$consoleTextbox.Text = "Attempting to connect to $compname"
    if(Test-Connection $compname -Quiet -Count 1){
        Enter-PSSession -ComputerName $compname -Credential $creds
        UpdateConsole("Connection Established")


    }else{
        $consoleTextbox.Text = "Could not establish a connection with $compname"
    }

}

Function OfferAssistance(){
    msra.exe /offerRA $comp
}


#Mark: SetupForm

#Define master window
$mainWindow = New-Object System.Windows.Forms.Form
$mainWindow.Size = New-Object System.Drawing.Size(500,600)
$mainWindow.Text = "Moe Remote Support Tool"
$mainWindow.MaximizeBox = $false
$mainWindow.FormBorderStyle = "Fixed3D"
$mainWindow.KeyPreview = $true
$mainWindow.Add_KeyDown({
    if($_.KeyCode -eq "Enter"){
        $compname = $connectionTextbox.Text
        establishSession($compname)
        }
    })
$mainWindow.Add_KeyDown({
    if($_.KeyCode -eq "Escape"){
        $mainWindow.Close()
        }
    })

#Define connection textbox
$connectionTextbox = New-Object System.Windows.Forms.TextBox
$connectionTextbox.Location = New-Object System.Drawing.Size(10,30)
$connectionTextbox.Size = New-Object System.Drawing.Size(150,100)
$mainWindow.Controls.Add($connectionTextbox)

#Label Textbox
$textboxLabel = New-Object System.Windows.Forms.Label
$x = $connectionTextbox.Location.X + 1
$y = $connectionTextbox.Location.Y - 20
$textboxLabel.Location = New-Object System.Drawing.Size($x,$y)
$textboxLabel.Size = New-Object System.Drawing.Size(100,20)
$textboxLabel.Text = "Computer Name"
$mainWindow.Controls.Add($textboxLabel)

#Define connect button
$connectButton = New-Object System.Windows.Forms.Button
$x = $connectionTextbox.Location.X + 160
$y = $connectionTextbox.Location.Y
$connectButton.Location = New-Object System.Drawing.Size($x,$y)
$connectButton.Size = New-Object System.Drawing.Size(100,30)
$connectButton.Text = "Connect"
$connectButton.Add_Click({
    $compname = $connectionTextbox.Text
    establishSession($compname)
})
$mainWindow.Controls.Add($connectButton)

#Define Console View
$consoleTextbox = New-Object System.Windows.Forms.Label
$x = $connectionTextbox.Location.X 
$y = $connectionTextbox.Location.Y + 50
$consoleTextbox.Location = New-Object System.Drawing.Size($x,$y)
$consoleTextbox.Size = New-Object System.Drawing.Size(470,150)
$consoleTextbox.Text = "Nothing entered"
$consoleTextbox.BorderStyle = "Fixed3D"
$mainWindow.Controls.Add($consoleTextbox)

#Username Label
$userLabel = New-Object System.Windows.Forms.Label
$userLabel.Location = New-Object System.Drawing.Size(310,13)
$userLabel.Size = New-Object System.Drawing.Size(60, 20)
$userLabel.Text = "Username:"
$mainWindow.Controls.Add($userLabel)

#Username textbox
$userTextbox = New-Object System.Windows.Forms.TextBox
$userTextbox.Location = New-Object System.Drawing.Size(370,10)
$userTextbox.Text = "$env:REGIONCODE\"
$mainWindow.Controls.Add($userTextbox)

#Password Label
$passwordLabel = New-Object System.Windows.Forms.Label
$passwordLabel.Location = New-Object System.Drawing.Size(310,43)
$passwordLabel.Size = New-Object System.Drawing.Size(60,20)
$passwordLabel.Text = "Password:"
$mainWindow.Controls.Add($passwordLabel)

#Password textbox
$passwordTextBox = New-Object System.Windows.Forms.MaskedTextBox
$passwordTextBox.Location = New-Object System.Drawing.Size(370, 40)
#$passwordTextBox.Size = New-Object System.Drawing.Size(100, 10)
$passwordTextBox.PasswordChar = "*"
$mainWindow.Controls.Add($passwordTextBox)

$mainWindow.Size.X
#Mark: Finalise Settings and show form
$mainWindow.ShowDialog()
Exit-PSSession
Return 0

$secpasswd = ConvertTo-SecureString $PasswordTextBox.Text -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ($userTextbox.Text, $secpasswd)