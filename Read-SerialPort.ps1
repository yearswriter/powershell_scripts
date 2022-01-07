[System.IO.Ports.SerialPort]::getportnames()
$port = new-Object System.IO.Ports.SerialPort COM3,9600,None,8,one
$port.open()
$port.ReadLine()

# https://devblogs.microsoft.com/powershell/writing-and-reading-info-from-serial-ports/
