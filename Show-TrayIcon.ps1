[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
function OnClick {
    $objNotifyIcon.Dispose()
    return 0
}

try {
  $objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon
  $objNotifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Windows\System32\shell32.dll")
  $objNotifyIcon.BalloonTipIcon = "Info"
  $objNotifyIcon.BalloonTipTitle = "Balloon tip title"
  $objNotifyIcon.BalloonTipText = "Baloon tip text"
  $objNotifyIcon.Text = "Icon text"
  $objNotifyIcon.Tag = "Icon tag"

  $objNotifyIcon.add_DoubleClick({OnClick})

  # This should be set before any actions, like showBaloonTip,
  # but after callbacks assigning, like double click event callback
  $objNotifyIcon.Visible = $True

  $objNotifyIcon.ShowBalloonTip(1000)
  Start-Sleep -Seconds 5 # do stuff here
} finally {
    $objNotifyIcon.Dispose()
}
