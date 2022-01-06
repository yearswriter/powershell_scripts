[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
function OnDoubleClick {
    $objNotifyIcon.Dispose()
    $form.Close()
    return 0
}
function ClickMe {
  Write-Host ('You clicked "' + $this.Text + '"') -fore Green
}
try {
  # creation of form is needed for icon context menu to be active
  $form = New-Object System.Windows.Forms.Form

  # bunch of stuff, hiding our form in gui (1)
  $form.WindowState = 1
  $form.ShowInTaskbar = $false
  $form.FormBorderStyle = 6

  # Creating context menu object and  filling it with ClickMeButton button
  $objNotifyIconContextMenu = New-Object System.Windows.Forms.ContextMenuStrip
  $ClickMeButton = $objNotifyIconContextMenu.Items.Add("Click me")

  # Assignin callback function for click on ClickMeButton
  $ClickMeButton.add_Click({ClickMe})

  # NotifyIcon object creation and setting all the settings
  $objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon
  # can also assept plain *.ico file path and extract icon from *.exe
  $objNotifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Windows\System32\shell32.dll")
  $objNotifyIcon.BalloonTipIcon = "Info"
  $objNotifyIcon.BalloonTipTitle = "Balloon tip title"
  $objNotifyIcon.BalloonTipText = "Baloon tip text"
  $objNotifyIcon.Text = "Icon text"
  $objNotifyIcon.Tag = "Icon tag"

  # Assignin callback function for double click event
  $objNotifyIcon.add_DoubleClick({OnDoubleClick})
  # Assigning context menu strip to icon
  $objNotifyIcon.ContextMenuStrip = $objNotifyIconContextMenu

  # This should be set before any actions, like showBaloonTip,
  # but after callbacks assigning, like double click event callback
  $objNotifyIcon.Visible = $True

  $objNotifyIcon.ShowBalloonTip(1000)

  # Form needs to exist to enable context menu
  $form.ShowDialog()

  Start-Sleep -Seconds 10 # do stuff here

} finally {
    $objNotifyIcon.Dispose()
    $form.Close()
}

#(1) https://www.csharp411.com/hide-form-from-alttab/
#    https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.formborderstyle?view=windowsdesktop-6.0
#    https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.form?view=windowsdesktop-6.0
