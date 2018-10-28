$list = @(
    "MATTDESKTOP"
)

$trustedhosts = Get-ChildItem WSMan:\localhost\Client\TrustedHosts | Select-Object Value
$trustedhosts
ForEach ($server in $list) {
  $server = $server.ToString()
  "to be added $server"
  $trustedhosts = $trustedhosts.ToString()
  $trustedhosts = ($server + ",$trustedhosts").TrimEnd(",")
  "list $trustedhosts"
}
""
set-item wsman:\localhost\Client\TrustedHosts -value $trustedhosts

Get-WSManInstance -ResourceURI winrm/config/client | Format-Table TrustedHosts -AutoSize -Wrap