function Get-FolderSize {
  [CmdletBinding()]
  Param (
  [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
  $Path
  )
  if ( (Test-Path $Path) -and (Get-Item $Path).PSIsContainer ) {
  $Measure = Get-ChildItem $Path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
  $Sum = '{0:N2}' -f ($Measure.Sum / 1Gb)
  [PSCustomObject]@{
  "Path" = $Path
  "Size(Gb)" = $Sum
  }
  }
  }

  function Get-SubFoldersSize {
    [CmdletBinding()]
    Param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    $Path
    )
    $dataColl = @()
    Get-ChildItem $Path | ForEach-Object {
      $dataColl += (Get-FolderSize $_.FullName)
    }
    $dataColl | Out-GridView -Title “Size of subdirectories”
  }
