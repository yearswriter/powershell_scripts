param (
  [Parameter(Mandatory = $true,
    HelpMessage = 'Full path to json config to convert from',
    Position = 1)]
  [ArgumentCompleter({
      param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
      $configs = Get-ChildItem *.conf
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
