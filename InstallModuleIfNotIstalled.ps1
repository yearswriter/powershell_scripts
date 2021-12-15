# TODO:
#   - Catch no internet\can't get repo
#   - Properly get out of the loop on error
#   - Find faster path if everything is good
#   - Catch if user did not agreed to install
while (-not (Get-Module -ListAvailable -Name ImportExcel)){
  try {
    Write-Host "Required module 'ImportExcel' not found, installing"
    Install-Module ImportExcel
  } catch {
    Write-Host $_
    Write-Host "Error while installing dependecies"
    #Goto :getmeout
  }
}
#:getmeout
try {
  Import-Module ImportExcel -ErrorAction Stop
} catch {
  Write-Host $_
  Write-Host "Failed to load required module 'ImportExcel"
}
