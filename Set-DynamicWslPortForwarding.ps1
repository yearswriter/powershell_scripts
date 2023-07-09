<#
.SYNOPSIS
	Opens WSL to external connections in and out
.DESCRIPTION
	This will port forward one or more ports from your
	host machine internet connection to the WSL
	by means of:
		 - getting wsl instance ip,
		 - removing old and setting new windows firewall rules,
		 - removing old and setting new portproxy
		 (on windows virtual interfaces using netsh)
.PARAMETER Ports
	Specifies ports which would be forwarded to and from wsl.

.PARAMETER ListenToIp
	Specifies interface on the host machine on which ports will be open. 0.0.0.0 listens to all.

.PARAMETER FirewallRuleName
	Specifies name of the host machine's firewall rule name

.PARAMETER WslUser
	Specifies wsl guest username to restart wsl services, in case it is needed

.PARAMETER ServicesToRestart
	Specifies comma-separated services name to restart on wsl machine, in case it is needed

.EXAMPLE
	.\Set-DynamicWslPortForwarding.ps1 -Ports 22 -ListenToIP '0.0.0.0' -FirewallRuleName 'WSL 2 Firewall Portforwarding' -WslUser user -ServicesToRestart ssh
.NOTES
	!make sure WSL OS firewall is configured accordingly!
#>
param(
	[Parameter(Mandatory)]
	[int[]]$Ports,
	[Parameter(Mandatory)]
	[string]$ListenToIP,
	[Parameter(Mandatory)]
	[ArgumentCompletions('"WSL portforward"')]
	[string]$FirewallRuleName,
	[string]$WslUser,
	[string[]]$ServicesToRestart# Some services on WSL may require restarting in my expierence
)
#Requires -Version 7
#Requires -RunAsAdministrator

# Creating string of ports for firewall rules
$PortsString = $Ports -join ','

# Figuring out wsl local IP
function GetWslIP {
	return  wsl ip -4 a show eth0 | awk 'FNR == 2 { /([0-9]+\.){3}[0-9]+/; sub (/\/[0-9]+/, \"\");print $2}'
	# Litte sanity check
	if ( -not ($WslLocalIp -match '(\d{1,3}\.){3}\d{1,3}')){
		exit
#TODO: Maybe also raise an error instead of just exiting
	}
}

function RestartWslServices{
	param(
		[string]$WslUser,
		[string[]]$ServicesToRestart
		)
	foreach ($Service in $ServicesToRestart){
		wsl -u $WslUser sudo /etc/init.d/$Service stop
		wsl -u $WslUser sudo /etc/init.d/$Service start
#TODO: Maybe check bash $? and raise an error if needed
	}
}

# Removing old and setting current firewall rules
# TODO: maybe error here possible, if there is no rule yet
Remove-NetFireWallRule -DisplayName $FirewallRuleName
New-NetFireWallRule -DisplayName $FirewallRuleName -Direction Outbound -LocalPort $PortsString -Action Allow -Protocol TCP
New-NetFireWallRule -DisplayName $FirewallRuleName -Direction Inbound  -LocalPort $PortsString -Action  Allow -Protocol TCP

# Removing old and settign current portproxy rules
foreach ($Port in $Ports) {
	netsh interface portproxy delete v4tov4 listenport=$Port listenaddress=$ListenToIP
	netsh interface portproxy add v4tov4 listenport=$Port listenaddress=$ListenToIP connectport=$Port connectaddress=$WslLocalIp
}

# restarting services if params not empty
if ($WslUser -and $ServicesToRestart){
	RestartWslServices -WslUser $WslUser -ServicesToRestart $ServicesToRestart
}
