#Requires -Version 7
#Requires -Modules ImportExcel
# This will get all connections with Get-NetTCPConnection cmdlet,
#  filter them by list of names provided in ProcessOfInterest variable
#  and display it in custom table

Set-Variable ProcessOfInterest -Option ReadOnly -Value *iot*,League* # Name(s) for a process(es) of interest
Set-Variable Output -Option ReadOnly -Value "./output.xlsx" # Name for output xlsx file
Set-Variable SheetName -Option ReadOnly -Value "process connections" # Name for output xlsx file

# Helper function to get hostname with Ip
function GetHost {
  param ([string]$Ip)
  try {
    return [System.Net.Dns]::GetHostByAddress($Ip).Hostname
  } catch {
    return "-"
  }
}
$gethostDef = $function:GetHost.ToString() # Serializing function to pass into ForEach-Object -Parallel (5)

# Get all TCP Connections whith our process names
$Connections = Get-NetTCPConnection `
  -AppliedSetting Internet ` # Filter conections optimised for internet (1)
  | Sort-Object -Property RemoteAddress ` # Sort by remote Addresses
  | where -Value "127.0.0.1" -NotIn -Property RemoteAddress ` # Filter locallhost connections
  | where -Property OwningProcess -In -Value (Get-Process -Name $ProcessOfInterest).Id ` # Filter by the Name for a process of interest
  | Select-Object -Property `
      OwningProcess, `
      LocalPort, `
      RemoteAddress, `
      RemotePort # Filter only fields that we need

# Enriching $Connections object (3)
$Connections | ForEach-Object -Parallel {
  $function:GetHost = $using:gethostDef # recreating function from string definition in every single context (5)
  $_ | Add-Member -NotePropertyName Ping -NotePropertyValue ((Test-Connection -TargetName $_.RemoteAddress -IPv4 -Count 1).Latency)
  $_ | Add-Member -NotePropertyName OwningProcessName -NotePropertyValue ((Get-Process -Id $_.OwningProcess).Name)
  $_ | Add-Member -NotePropertyName Hostname -NotePropertyValue(GetHost $_.RemoteAddress)
  $_ | Add-Member -NotePropertyName CommandLine -NotePropertyValue((Get-Process -Id $_.OwningProcess).CommandLine)
  }

# Outputing to STDIO with custom table formatting
$Connections | Format-Table `
  @{Label = "OwningProcessName";Expression = {[string]($_.OwningProcessName)}}, `
  @{Label = "LocalPort";Expression = {[int]($_.LocalPort)}}, `
  @{Label = "RemoteAddress";Expression = {[string]($_.RemoteAddress)}}, `
  @{Label = "Port";Alignment = "Left";Expression = {[int]($_.RemotePort)}}, `
  @{Label = "Ping";Expression = {[int]$_.Ping}}, `
  @{Label = "Hostname";Expression = {[string]($_.Hostname)}}

# Outputing to excel using ImportExcel module (4)
$Connections | Export-Excel $Output -WorksheetName $SheetName -TitleBold -AutoSize -FreezeTopRow -AutoFilter

# Footnote:
#   1. Applied settings https://docs.microsoft.com/en-us/powershell/module/nettcpip/set-nettcpsetting?view=windowsserver2022-ps
#   2. Custom output tables https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/format-table?view=powershell-7.2
#   3. Adding custom properties and methods to PS object https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/add-member?view=powershell-7.2
#   4. help export-excel
#   5. Powershell have problems with function pasing https://stackoverflow.com/questions/61273189/how-to-pass-a-custom-function-inside-a-foreach-object-parallel
