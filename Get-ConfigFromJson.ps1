param (
  [Parameter(Mandatory=$true)]
  [string]$ConfigFile
)

$ConfigPath = (Get-Location).path + "\" + $ConfigFile
$Config =  Get-Content $ConfigPath | ConvertFrom-Json
return $Config
