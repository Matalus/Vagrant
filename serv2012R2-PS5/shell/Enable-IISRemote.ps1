#checks for IIS EnableRemoteConnections Reg Key and injects if not exist

$Key = "HKLM:\SOFTWARE\Microsoft\WebManagement\Server\EnableRemoteManagement"

$GetKey = Get-Item $Key -ErrorAction SilentlyContinue

if(!$GetKey){
   "Adding Key"
   Try{
      New-Item $Key -Value 1
   }Catch{}
}else{
   "Key Exists"
}

Get-Item $Key