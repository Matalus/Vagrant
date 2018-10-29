#Bootstrap script to open up port 5985 for WINRM

Write-Output "Opening Up Firewall for WINRM"
Get-NetFirewallPortFilter | Where-Object{
  $_.LocalPort -eq 5985 
} | Get-NetFirewallRule | Where-Object{ 
  $_.Direction -eq "Inbound" -and 
  $_.Profile -eq "Public" -and 
  $_.Action -eq "Allow"
} | Set-NetFirewallRule -RemoteAddress "Any"