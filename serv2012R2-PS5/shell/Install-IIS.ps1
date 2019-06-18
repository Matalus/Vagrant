#Attempt to install 
$Features = @(
   "Web-Server",
   "Web-Mgmt-Console",
   "Web-Mgmt-Service",
   "Web-ASP-Net45"
)

ForEach($feature in $Features){
   $Installed = Get-WindowsFeature -Name $feature
   if($Installed -and $Installed.InstallState -eq "Installed"){
      "Feature : $feature : already installed"
   }else{
      "Feature : $feature : not installed - installing..."
      Add-WindowsFeature -Name $feature
   }
}