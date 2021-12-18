# Usefull Powershell snippets
#### ConnectionsWithProcessName
- Show processes connections filtering by their name or names,
    understands wildcards, saves to excel with ImportExcel
- By default does not resolves DN, and does not provide latency, enabled with
    -DoGetHost and -DoPing switch parameters e.g.:
    ```powershell
    .\ConnectionsWithProcessName.ps1 -DoGetHost -DoPing *fox,*earch*
    ```
#### DynamicWslPortForwarding
- Portforwarding for wsl machine, e.g. for ssh to wsl to be on the 22-nd Windows port:
    ```powershell
    .\DynamicWslPortForwarding.ps1 -Ports 22 -ListenToIP '0.0.0.0' -WslFirewallRuleName 'WSL 2 Firewall Porforwarding' -WslUser user -ServicesToRestart ssh
    ```
- WslUser and ServicesToRestart are optionaly restart any services
on wsl instance that need it, for uninteractive restart appropriate sudo rules to be configured on wsl, or it will silently fail e.g.
```%sshd    ALL=NOPASSWD:/etc/init.d/ssh```
- Restart commands are in ```RestartWslServices``` function
- Use it with custom scheduler task
```batch
    %PATH_TO_POWERSHELL%\pwsh.exe -windowstyle hidden -file %PATH_TO_SCRIPTS%\DynamicWslPortForwarding.ps1
```
that triggers on event:
```XML
<QueryList>
  <Query Id="0" Path="Microsoft-Windows-Dhcp-Client/Admin">
    <Select Path="Microsoft-Windows-Dhcp-Client/Admin">*[System[Provider[@Name='Microsoft-Windows-Dhcp-Client'] and (Computer='ComputerName') and Task = 3 and (EventID=50065 or EventID=50066) and Security[@UserID='UserSID']]]</Select>
    <Select Path="Microsoft-Windows-Dhcp-Client/Operational">*[System[Provider[@Name='Microsoft-Windows-Dhcp-Client'] and (Computer='ComputerName') and Task = 3 and (EventID=50065 or EventID=50066) and Security[@UserID='UserSID']]]</Select>
    <Select Path="System">*[System[Provider[@Name='Microsoft-Windows-Dhcp-Client'] and (Computer='ComputerName') and Task = 3 and (EventID=50065 or EventID=50066) and Security[@UserID='UserSID']]]</Select>
  </Query>
```
you can check the events in logging facility with this filter:
```XML
<QueryList>
  <Query Id="0" Path="Microsoft-Windows-Dhcp-Client/Admin">
    <Select Path="Microsoft-Windows-Dhcp-Client/Admin">*[System[Provider[@Name='Microsoft-Windows-Dhcp-Client' or @Name='Microsoft-Windows-DHCPv6-Client']]]</Select>
    <Select Path="Microsoft-Windows-Dhcp-Client/Operational">*[System[Provider[@Name='Microsoft-Windows-Dhcp-Client' or @Name='Microsoft-Windows-DHCPv6-Client']]]</Select>
    <Select Path="Microsoft-Windows-Dhcpv6-Client/Operational">*[System[Provider[@Name='Microsoft-Windows-Dhcp-Client' or @Name='Microsoft-Windows-DHCPv6-Client']]]</Select>
    <Select Path="Microsoft-Windows-Dhcpv6-Client/Admin">*[System[Provider[@Name='Microsoft-Windows-Dhcp-Client' or @Name='Microsoft-Windows-DHCPv6-Client']]]</Select>
    <Select Path="System">*[System[Provider[@Name='Microsoft-Windows-Dhcp-Client' or @Name='Microsoft-Windows-DHCPv6-Client']]]</Select>
  </Query>
</QueryList>
```
userSID and computer name can be obtained with
```powershell
    $env:computername
    (Get-LocalUser -Name $env:username).sid
```
