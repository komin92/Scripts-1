#Written by Mitchell Beare <MitchellBeare@gmail.com>

$File = "\\Mac\Home\Desktop\AirServer Installer\AirServer.msi"
$Args = @(
    "/i"
    ('"{0}"' -f $File.ToString())
    "/passive"
    "/qb"
    "/norestart"
    "PIDKEY=1234"
    "AUTOSTART=ENABLE"
    )

Start-Process msiexec.exe -ArgumentList $Args -Wait