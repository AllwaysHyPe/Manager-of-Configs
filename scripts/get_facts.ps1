# get vm IP address based off of host IP address
$result = @{ }

$IP = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "8.8.8.*" -and $_.IPAddress -ne "172.0.0.1" } | Select-Object -First 1 -ExpandProperty IPAddress


# Split IP into octets
$Octets = $IP.Split('.')

$Octets[2] = [int]$Octets[2] + 1

# Create new IP address
$NewIP = "$($Octets[0]).$($Octets[1])..$($Octets[2])..$($Octets[3])."
$result['vm_ipaddress'] = $NewIP
