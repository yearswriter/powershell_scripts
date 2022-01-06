function Start-WindowsTerminalSplit4 {
    param(
        $command1 = "pwsh",
        $command2 = "pwsh",
        $command3 = "pwsh",
        $command4 = "pwsh"
        )
    Start-Process wt -ArgumentList "new-tab $command1; split-pane -H $command2; mf up split-pane $command3; mf down split-pane $command4" -passthru
}
