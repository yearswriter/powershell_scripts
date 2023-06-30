try {
  $dllPath = "C:\Users\years\.nuget\packages\microsoft.web.webview2\1.0.902.49\lib\netcoreapp3.0"
  Add-Type -AssemblyName System.Windows.Forms
  Add-Type -AssemblyName System.Drawing
  [void][reflection.assembly]::LoadFile("$dllPath\Microsoft.Web.WebView2.WinForms.dll")
  [void][reflection.assembly]::LoadFile("$dllPath\Microsoft.Web.WebView2.Core.dll")
  [void][reflection.assembly]::LoadFile("$dllPath\Microsoft.Web.WebView2.Wpf.dll")

  # Create the form
  $form = New-Object System.Windows.Forms.Form
  $form.Size = New-Object System.Drawing.Size(800, 600)

  # Create the environment options
  $envOptions = New-Object Microsoft.Web.WebView2.Core.CoreWebView2EnvironmentOptions
  $envOptions.AdditionalBrowserArguments = '--remote-debugging-port=9222'

  # Create the environment
  $env = [Microsoft.Web.WebView2.Core.CoreWebView2Environment]::CreateAsync($null, $null, $envOptions).GetAwaiter().GetResult()

  # Create the WebView2 control
  $webView = New-Object Microsoft.Web.WebView2.WinForms.WebView2
  $webView.Dock = [System.Windows.Forms.DockStyle]::Fill

  # Initialize the WebView2 control with the environment
  $webView.EnsureCoreWebView2Async($env) | Out-Null


  # Ensure the WebView2 environment is initialized
  $webView.EnsureCoreWebView2Async() | Out-Null

  # Add the WebView2 control to the form
  $form.Controls.Add($webView)

  # Navigate to a URL when the CoreWebView2 is ready
  $webView.add_CoreWebView2InitializationCompleted({
      $webView.CoreWebView2.Navigate('https://www.bing.com')
    })

}
catch {
  # Write the exception message to the console
  Write-Host $_.Exception.Message
}

# Show the form
$form.ShowDialog()
