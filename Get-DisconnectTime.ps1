param(
  [Parameter()]
  [ArgumentCompletions('pesheevpavel.ru', 'google.com')]
  [string]$Watch = 'google.com'
)
Start-Job -Name InternetGuard -ArgumentList $Watch -ScriptBlock {
  param($Watch)
  $Voice = New-Object -ComObject SAPI.SPVoice
  $Voice.Voice = $Voice.GetVoices()[0]
  [void] $Voice.Speak('Запускаю наблюдателя за интернет-соединением.')
  $t = Test-NetConnection -ComputerName $Watch
  $internet = $t.PingSucceeded
  Write-Host $objNotifyIcon.Visible
  Do {
    while ($internet) {
      Start-Sleep -s 5
      $internet = (Test-NetConnection -ComputerName $Watch).PingSucceeded
    }
    [void] $Voice.Speak('Проблемы соединения! Запускаю ждуна рабочего подключения.')
    while (-Not $internet) {
      Start-Sleep -s 5
      $internet = (Test-NetConnection -ComputerName $Watch).PingSucceeded
    }
    [void] $Voice.Speak('Интернет появился!')
  } While ($True)
}

try {
  [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
  $Voice = New-Object -ComObject SAPI.SPVoice
  $Voice.Voice = $Voice.GetVoices()[0]
  function CloseGuard {
    [void] $Voice.Speak('Останавливаю наблюдателя.')
    $objNotifyIcon.Visible = $False
    $objNotifyIcon.Dispose()
    Get-job -Name InternetGuard | Remove-Job -Force
  }

  $objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon
  $objNotifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Windows\System32\telnet.exe")
  $objNotifyIcon.add_DoubleClick({ CloseGuard })
  $objNotifyIcon.Text = "Наблюдатель за интернетом"
  $objNotifyIcon.Tag = "InternetGuard."
  $objNotifyIcon.Visible = $True
  Get-Job -Name InternetGuard | Wait-Job
}
finally {
  $objNotifyIcon.Visible = $False
  $objNotifyIcon.Dispose()
}
