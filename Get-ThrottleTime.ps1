[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$DoWorkHere = {
  param($objNotifyIcon)
  function Get-ClockAndTemperature {
    $sensors = $(Get-CimInstance -Namespace Root\OpenHardwareMonitor -Class sensor)
    $clock =  [math]::Truncate(
      $($sensors | Where-Object {
        $_.SensorType -eq "Clock" -and $_.Name -eq "CPU Core #1"
      } | Select-Object -Property Value).Value
      )

      $temperature = $($sensors | Where-Object {
        $_.SensorType -eq "Temperature" -and $_.Name -eq "CPU Core #1"
      } | Select-Object -Property Value).Value

      $objNotifyIconText = "${clock}|${temperature}"

      return @{
        clock = $clock
        temperature = $temperature
        objNotifyIconText = $objNotifyIconText
      }

  }
  $Voice = New-Object -ComObject SAPI.SPVoice
  $Voice.Voice = $Voice.GetVoices()[1]
  Do {
    $probeResults = Get-ClockAndTemperature
    $clock = $probeResults.clock
    $temperature = $probeResults.temperature
    $objNotifyIcon.Text = $probeResults.objNotifyIconText
    [void] $Voice.Speak("Full speed")
    while ([int]$clock -ge 2000){
      start-sleep -Seconds 1
      $probeResults = Get-ClockAndTemperature
      $clock = $probeResults.clock
      $temperature = $probeResults.temperature
      $objNotifyIcon.Text = $probeResults.objNotifyIconText
    }
    [void] $Voice.Speak("Throttle at ${temperature} degrees to ${clock} hertz")
    while ([int]$clock -lt 2000){
      start-sleep -Seconds 1
      $clock = $probeResults.clock
      $temperature = $probeResults.temperature
      $objNotifyIcon.Text = $probeResults.objNotifyIconText
      $probeResults = Get-ClockAndTemperature
    }
    } While ($true)
}

$ExitBlock = {
  Get-Job -Name DoWorkHere | Remove-Job -Force
  $objNotifyIcon.Visible = $False
  $objNotifyIcon.Dispose()
  $form.Close()
  return 0
}

# creation of form is needed for icon context menu to be active
$form = New-Object System.Windows.Forms.Form

# bunch of stuff, hiding our form in gui (1)
$form.WindowState = 1
$form.ShowInTaskbar = $false
$form.FormBorderStyle = 6
$form.Opacity = 0

# Creating context menu object and  filling it with ClickMeButton button
$objNotifyIconContextMenu = New-Object System.Windows.Forms.ContextMenuStrip
$ClickMeButton = $objNotifyIconContextMenu.Items.Add("Exit")

# Assignin callback function for click on ClickMeButton
$ClickMeButton.add_Click($ExitBlock)

# NotifyIcon object creation and setting all the settings
$objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon
# can also assept plain *.ico file path and extract icon from *.exe
$objNotifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Windows\System32\shell32.dll")
$objNotifyIcon.Text = "Icon text"
$objNotifyIcon.Tag = "Icon tag"

# Assignin callback function for double click event
$objNotifyIcon.add_DoubleClick($ExitBlock)
# Assigning context menu strip to icon
$objNotifyIcon.ContextMenuStrip = $objNotifyIconContextMenu

try {
# This should be set before any actions, like showBaloonTip,
# but after callbacks assigning, like double click event callback
$objNotifyIcon.Visible = $True

# Start-Thread job to be able to interact with tray icon from the job
# without serialisation\deserialisation headache
Start-ThreadJob -ArgumentList $objNotifyIcon -Name DoWorkHere -ScriptBlock $DoWorkHere

# form needs to exist for us to interact with context menu
$form.ShowDialog()
} catch {
  $_
}
