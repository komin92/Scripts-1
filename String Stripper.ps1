$null = Add-Type -AssemblyName System.windows.forms
$OpenFileDialog = New-Object -TypeName System.Windows.Forms.OpenFileDialog
$OpenFileDialog.filter = 'All files (*.*)| *.*'
$null = $OpenFileDialog.ShowDialog()
$path = $OpenFileDialog.filename
$strings = Get-Content -Path $path
$strings = $strings.Replace('"','') | Out-File -FilePath $path