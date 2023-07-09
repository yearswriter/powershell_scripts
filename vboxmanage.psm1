Function vboxmanage_nologo { vboxmanage --nologo $args }
Set-Alias -Name vbm -Value vboxmanage_nologo

<#
 .Synopsis
  Version of vboxmanage tool.

 .Description
  Displays the version of vboxmanage tool and exits.

 .Example
   # Show the version of this tool and exit.
   Show-VboxVersion

#>
function Show-VboxVersion {
  Write-Host $(vbm --version)
}
<#
 .Synopsis
  Get a list of VboxVM objects of all aviable vms.

 .Description
  Retrieves a list of VboxVM objects of all aviable vms.

 .Example
   # Show the version of this tool and exit.
   Get-Vm

#>
function Get-Vm {

}

Export-ModuleMember -Function Show-VboxVersion
Export-ModuleMember -Function Get-Vm
