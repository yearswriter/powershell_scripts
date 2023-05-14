param (
  [Parameter(Mandatory = $true,
    HelpMessage = 'Full path to config file to convert from')]
  [ArgumentCompleter({
      param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
      $configs = Get-ChildItem | Where-Object {
        $_.Extension -match 'conf' -Or $_.Extension -match 'json'
      }
      foreach ($config in $configs) {
        New-Object -Type System.Management.Automation.CompletionResult -ArgumentList $config.FullName,
        $config.FullName,
        "ParameterValue",
        $config.FullName
      }
    })]
  [string]$ConfigFile
)

$Config = Get-Content $ConfigFile | ConvertFrom-Json
return $Config
