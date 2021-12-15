#Requires -Version 7
# This will get all connections with Get-NetTCPConnection cmdlet,
#  filter them by list of names provided in ProcessOfInterest variable
#  and display it in custom table

Set-Variable ProcessOfInterest -Option ReadOnly -Value *iot*,League* # Name(s) for a process(es) of interest

# Get all TCP Connections
Get-NetTCPConnection `
  -AppliedSetting Internet ` # Filter conections optimised for internet (1)
  | Sort-Object -Property RemoteAddress ` # Sort by remote Addresses
  | where -Value "127.0.0.1" -NotIn -Property RemoteAddress ` # Filter locallhost connections
  | where -Property OwningProcess -In -Value (Get-Process -Name $ProcessOfInterest).Id ` # Filter by the Name for a process of interest
  | Format-Table `
  @{Label = "OwningProcessName";Expression = {[string](Get-Process -Id $_.OwningProcess).Name}}, `
  @{Label = "LocalPort";Expression = {[int]($_.LocalPort)}}, `
  @{Label = "RemoteAddress";Expression = {[string]($_.RemoteAddress)}}, `
  @{Label = "Port";Alignment = "Left";Expression = {[int]($_.RemotePort)}}, `

  @{Label = "Ping";Expression = {[int]((Test-Connection -TargetName $_.RemoteAddress -IPv4 -Count 1).Latency)}} ` # Custom output table (2)

# Footnote:
#   1. Applied settings https://docs.microsoft.com/en-us/powershell/module/nettcpip/set-nettcpsetting?view=windowsserver2022-ps
#   2. Custom output tables https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/format-table?view=powershell-7.2
# Also command line can be usefulll? @{Label = "CommandLine";Expression = {[string]((Get-Process -Id $_.OwningProcess).CommandLine)}}
# @{Label = "OwningProcessId";Expression = {[int]($_.OwningProcess)}}, `
