#checks for IIS EnableRemoteConnections Reg Key and injects if not exist

$Key = "HKLM:\SOFTWARE\Microsoft\WebManagement\Server\EnableRemoteManagement"

$GetKey = Get-Item $Key

if(!$GetKey){
   "Adding Key"
   New-Item $Key -Value 1
}else{
   "Key Exists"
}

Get-Item $Key