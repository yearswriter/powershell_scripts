Get-CimInstance -Namespace OpenHardwareMonitor -ClassName __Namespace
Get-CimInstance -Namespace Root\OpenHardwareMonitor -Class sensor

# TODO: explore https://www.reddit.com/r/PowerShell/comments/pjvoxm/get_cpu_temperature_wo_wmi/
# Add-Type -Path .\OpenHardwareMonitorLib.dll
